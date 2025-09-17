Aggiorna la quantità di una riga di pianificazione inventario e crea entry di inventario

```cs ccp fold title:UpdateInventoryOrders 

		[HttpPost]
		public object UpdateInventoryOrderLine(UpdateInventoryLineRequest Request)
		{
			try
			{
				using (DBK_SuiteEntities db = new DBK_SuiteEntities())
				{
					WSpaceUtility.CheckBasicRequestData(Request);

					if (string.IsNullOrEmpty(Request.OrderNo))
					{
						return BadRequest("OrderNo è obbligatorio");
					}

					if (Request.OrderLineID <= 0)
					{
						return BadRequest("OrderLineID è obbligatorio");
					}

					// Get the planning line
					var planningLine = db.WAR_PlanningLine.FirstOrDefault(l => 
						l.OrderID == Request.OrderNo && l.OrderLineID == Request.OrderLineID);
					
					if (planningLine == null)
					{
						return BadRequest($"Riga ordine {Request.OrderLineID} non trovata per l'ordine {Request.OrderNo}");
					}

					decimal adjustmentValue = 0;
					decimal newCountedQuantity = planningLine.CountedQuantity;
					bool isAdjustment = false;
					

					// Parse adjustment quantity (+1, -2, etc.) or use counted quantity
					if (!string.IsNullOrEmpty(Request.AdjustmentQuantity))
					{
						if (!decimal.TryParse(Request.AdjustmentQuantity, out adjustmentValue))
						{
							return BadRequest("Formato AdjustmentQuantity non valido. Usare formato come +1, -2, etc.");
						}

						newCountedQuantity = planningLine.CountedQuantity + adjustmentValue;
						isAdjustment = true;
					}
					else if (Request.CountedQuantity.HasValue)
					{
						newCountedQuantity = Request.CountedQuantity.Value;
						adjustmentValue = newCountedQuantity - planningLine.CountedQuantity;
					}
					else
					{
						return BadRequest("Specificare AdjustmentQuantity o CountedQuantity");
					}

					// Update planning line
					planningLine.CountedQuantity = newCountedQuantity;
					planningLine.Status = 1;
					
					// Check if quantities match to set status to completed (using CustDecimal1 as status field)
					if (adjustmentValue == 0 || newCountedQuantity == planningLine.Quantity)
					{
						planningLine.CustDecimal1 = 1; // Completed status
					}

					// Create WAR_InventoryEntry
					var inventoryEntry = new WAR_InventoryEntry
					{
						EntryID = Guid.NewGuid().ToString(),
						InsertDateTime = DateTime.Now,
						OrderNo = Request.OrderNo,
						OrderLineID = Request.OrderLineID.ToString(),
						FromBinNo = planningLine.FromBinNo,
						ToBinNo = planningLine.ToBinNo,
						ItemNo = planningLine.ItemNo,
						AdjustmentQuantity = (int)adjustmentValue, // Store only + or - adjustment
						ActionPerformed = isAdjustment ? 1 : 2, // 1 = adjustment, 2 = count
						IsManualEntry = false,
						isConfirmed = false,
						CustString1 = Request.RequestResourceID ?? "",
						CustString2 = Request.RequestDevice ?? "",
						CustString3 = "",
						CustDecimal1 = newCountedQuantity,
						CustDecimal2 = planningLine.Quantity, // Original expected quantity
						CustDecimal3 = adjustmentValue,
						CustBool1 = false,
						CustBool2 = false,
						CustDate1 = DateTime.Now
					};

					// Save changes
					db.WAR_InventoryEntry.Add(inventoryEntry);
					db.SaveChanges();

					return Ok(new
					{
						Success = true,
						Message = "Riga inventario aggiornata con successo",
						Data = new
						{
							PlanningLine = planningLine,
							InventoryEntry = inventoryEntry,
							PreviousCountedQuantity = planningLine.CountedQuantity - adjustmentValue,
							NewCountedQuantity = newCountedQuantity,
							AdjustmentValue = adjustmentValue,
							IsCompleted = planningLine.CustDecimal1 == 1
						}
					});
				}
			}
			catch (Exception e)
			{
				return BadRequest(Message.ErrorOutput(e, "UpdateInventoryOrderLine", Request?.RequestDevice));
			}
		}

```