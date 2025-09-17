Vecchio endpoint che ci consentiva di creare e popolare WAR_PlanningLines 

```c# ccp fold title:CreateInventoryLines
		/// <summary>
		 /// Crea e salva le righe di pianificazione inventario nel database
		 /// </summary>
		 [HttpPost]
		 public object CreateInventoryOrderLines(JSWarInventoryOrderRequest Request)
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

					 // Get the planning header for this order
					 var planningHeader = db.WAR_PlanningHeader.FirstOrDefault(h => h.OrderID == Request.OrderNo);
					 if (planningHeader == null)
					 {
						 return BadRequest($"Ordine {Request.OrderNo} non trovato");
					 }

					 // Check if lines already exist for this order
					 var existingLines = db.WAR_PlanningLine.Where(l => l.OrderID == Request.OrderNo).ToList();
					 if (existingLines.Any())
					 {
						 return BadRequest($"Le righe per l'ordine {Request.OrderNo} sono già state create");
					 }

					 // Get all WAR_PlanningINBin entries for this order
					 var planningBins = db.WAR_PlanningINBin.Where(p => p.OrderNo == Request.OrderNo).ToList();

					 var planningLines = new List<WAR_PlanningLine>();
					 var gdbBinEntry = new GDB.WARBinEntry();
					 int lineCounter = 1;

					 foreach (var planningBin in planningBins)
					 {
						 // Create a request object for the bin
						 var binRequest = new JSWarRequest
						 {
							 LocationNo = planningBin.LocationNo,
							 ZoneNo = planningBin.ZoneNo,
							 RequestDevice = Request.RequestDevice,
							 RequestResourceID = Request.RequestResourceID
						 };

						 // Get bin items for this bin
						 var binItems = gdbBinEntry.GetBinItemList(db, binRequest, planningBin.BinNo);

						 // Create planning lines from bin items
						 foreach (var binItem in binItems)
						 {
							 var planningLine = new WAR_PlanningLine
							 {
								 OrderID = Request.OrderNo,
								 OrderLineID = lineCounter++,
								 OrderKey = $"{Request.OrderNo}-{lineCounter - 1}",
								 Type = planningBin.Type,
								 Status = 0, // Initial status
								 Description = binItem.ItemDescription ?? "",
								 UnitOfMeasure = binItem.UnitOfMeasure ?? "",
								 PackagingQuantity = 0,
								 TransitQuantity = 0,
								 NewQuantity = 0,
								 LotNo = binItem.LotNo ?? "",
								 SerialNo = "",
								 BoxHeaderNo = binItem.BoxHeaderNo ?? "",
								 ItemNo = binItem.ItemNo,
								 ItemCategoryNo = "",
								 LocationNo = binItem.LocationNo,
								 ZoneNo = binItem.ZoneNo,
								 BinNo = binItem.BinNo,
								 DueDate = null,
								 StartingDate = null,
								 StartingTime = null,
								 EndingDate = null,
								 EndingTime = null,
								 IsCompleted = false,
								 CompletedByResourceNo = "",
								 ErrorDescription = "",
								 CustString1 = "",
								 CustString2 = "",
								 CustString3 = "",
								 CustString4 = "",
								 CustDecimal1 = 0,
								 CustDecimal2 = 0,
								 CustDecimal3 = 0,
								 CustBool1 = false,
								 CustBool2 = false,
								 CustDate1 = null,
								 CustDate2 = null,
								 Quantity = binItem.RemainingQuantity,
								 CountedQuantity = 0,
								 RemainingQuantity = binItem.RemainingQuantity,
								 FromLocationNo = binItem.LocationNo,
								 ToLocationNo = "",
								 FromBinNo = binItem.BinNo,
								 ToBinNo = ""
							 };

							 planningLines.Add(planningLine);
						 }
					 }

					 // Save planning lines to database
					 db.WAR_PlanningLine.AddRange(planningLines);
					 db.SaveChanges();

					 // Costruzione risposta seguendo lo standard della soluzione
					 if (Request.LoadConfig)
					 {
						 return Ok(new
						 {
							 Success = true,
							 Message = $"Create {planningLines.Count} righe per l'ordine {Request.OrderNo}",
							 Data = new
							 {
								 PageConfig = PageConfigUtility.GetConfigPages("WAR_InventoryOrderItems", Request),
								 Header = planningHeader,
								 Lines = planningLines
							 }
						 });
					 }
					 else
					 {
						 return Ok(new
						 {
							 Success = true,
							 Message = $"Create {planningLines.Count} righe per l'ordine {Request.OrderNo}",
							 Data = new
							 {
								 Header = planningHeader,
								 Lines = planningLines
							 }
						 });
					 }
				 }
			 }
			 catch (Exception e)
			 {
				 return BadRequest(Message.ErrorOutput(e, "CreateInventoryOrderLines", Request?.RequestDevice));
			 }
		 }

```