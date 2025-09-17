tutti gli oggetti con giacenze nel magazzino 
```ts ccp fold title:GetAllAvailableItems

  actions.push({

    actionID: ActionID.TEST,

    actionPerformed: async () => {

      try {

        // 2.3.0.61 #commitIdlatest: Esempio di chiamata mock per ottenere gli articoli disponibili

        await this.appManagerProvider.handleDefaultLoading(async () => {

          const response = await this.serverProvider.httpPost("/Api/WARBin/GetAllAvailableItems", {});

          const availableItems = response.AvailableItems;

          // Log degli articoli disponibili (solo per test)

          console.log("Available items:", availableItems);

        });

      } catch (err) {

        this.controllerProvider.showErrorAlert(err);

      }

    },

    imagePath: "assets/img/bug.png",

    tooltip: "Testa Funzionalità",

  });
```

in #file:order-list.ts  extract all the actions performed into an array, then move the array to #file:mock-order-actions.ts , in this file i want the actions organised like this const actionMocK() and then inside the array simply call the action inside actionPerformed, inside of #file:mock-actions-id.ts  create the new ids in an enum, removing them from #file:action-id.ts , finally inside the #file:order-list.ts  map the array as #file:orders-header-actions.ts  