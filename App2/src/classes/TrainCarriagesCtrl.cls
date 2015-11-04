public class TrainCarriagesCtrl {
	public Id trainId {get;set;}
	public Id carriageId {get;set;}
	public List<Carriage__c> addedCarriages {get;set;}
	public Id routeId {get;set;}
	public Boolean disabledTrainList {get;set;} 
	public List<SelectOption> trainsOptionList {get;set;}
	public List<SelectOption> carriagesOptionList {get;set;}
	public TrainCarriagesCtrl() {
		addedCarriages = new List<Carriage__c> ();
		routeId = ApexPages.currentPage().getParameters().get('routeId');
		disabledTrainList = false;
		if (carriagesOptionList == null) {
			carriagesOptionList = new List<SelectOption> ();
			getCarriageOptions();
		}
		if (trainsOptionList == null) {
			trainsOptionList = new List<SelectOption> ();
			getTrainOptions();
		}
	}
	
	// get all trains
	public List<Train__c> getTrains() {
		List<Train__c> trains = new List<Train__c> ();
		trains = [SELECT Id, Name, Type__c FROM Train__c];	
		return trains;
	}
	
	// get all trains ids after occupied time
	public List<Id> getAvailableTrainsIds() {
		List<Platform_Of_Route__c> platformsOnRoute = [SELECT Arrival_Time__c FROM Platform_Of_Route__c WHERE Route__c = :routeId order by Arrival_Time__c];
		List<Train_on_Route__c> trainsAvailableOnTime = [SELECT Train__c FROM Train_on_Route__c WHERE Occupied_Until__c < :platformsOnRoute[0].Arrival_Time__c];
		List<Id> availableTrainsId = new List<Id> ();
		for (Train_on_Route__c tr : trainsAvailableOnTime) {
			availableTrainsId.add(tr.Train__c);
		}
		return availableTrainsId;
	}
	
	// get all available trains
	public List<Train__c> getAvailableTrains() {
		List<Id> trainsIds = getAvailableTrainsIds();
		List<Train__c> trains = new List<Train__c> ();
		trains = [SELECT Id, Name, Type__c FROM Train__c WHERE Id IN :trainsIds];	
		return trains;
	}
	
	// create select option list of trains
	public List<SelectOption> getTrainOptions() {
		List<Train__c> trains = getAvailableTrains();
		for (Train__c tr : trains) {
			trainsOptionList.add(new SelectOption(tr.Id, tr.Name));
		}
		return trainsOptionList;
	}
	
	// get all carriages
	public List<Carriage__c> getCarriages() {
		List<Carriage__c> carriages = new List<Carriage__c> ();
		carriages = [SELECT Id, Name, Number_Of_Seats__c, Bicycles_Transport__c, Class__c, 
			Carriage_With_Tables__c, Disabled_People_Support__c FROM Carriage__c];	
		return carriages;
	}
	
	// get all available carriages
	public List<Carriage__c> getAvailableCarriages() {
		List<Id> availableTrainsIds = getAvailableTrainsIds();

		List<Carriage_on_Train__c> carriagesAvailable = [SELECT Carriage__c FROM Carriage_on_Train__c WHERE Train__c IN :availableTrainsIds ];
		List<Id> availableCarriagesId = new List<Id> ();
		for (Carriage_on_Train__c cr : carriagesAvailable) {
			availableCarriagesId.add(cr.Carriage__c);
		}
		
		List<Carriage__c> carriages = new List<Carriage__c> ();
		carriages = [SELECT Id, Name, Number_Of_Seats__c, Bicycles_Transport__c, Class__c,
							Carriage_With_Tables__c, Disabled_People_Support__c 
					 FROM Carriage__c 
					 WHERE Id IN :availableCarriagesId];	
		return carriages;
	}
	
	// get carriage by id param
	public Carriage__c getCarriageById(Id crId) {
		Carriage__c carriages = new Carriage__c ();
		carriages = [SELECT Id, Name, Number_Of_Seats__c, Bicycles_Transport__c, Class__c, 
			Carriage_With_Tables__c, Disabled_People_Support__c FROM Carriage__c WHERE Id = :crId];	
		return carriages;
	}
	
	// create select option list of carriages
	public void getCarriageOptions() {
		List<Carriage__c> carriages = getAvailableCarriages();
		for (Carriage__c cr : carriages) {
			String optionString = cr.Name + '; class:' + cr.Class__c + '; seats:' + cr.Number_Of_Seats__c;
			if (cr.Disabled_People_Support__c) {
				optionString += ';disabled people support';
			}
			if (cr.Bicycles_Transport__c) {
				optionString += ';bicycles transport';
			}
			carriagesOptionList.add(new SelectOption(cr.Id, optionString) );
		}
	}
	
	// add carriage to new route
	public PageReference addCarriageToList() {
		disabledTrainList = true;
		for (Integer i = 0; i < carriagesOptionList.size(); i++) {
			if (carriagesOptionList[i].getValue() == carriageId) {
				carriagesOptionList.remove(i);
				break;
			}
		}
		Carriage__c c = new Carriage__c();
		c = getCarriageById(carriageId);
		addedCarriages.add(c);
		return null;
	}
	
	// add carriages to carriages_on_train junction and save train_on_route
	public PageReference saveCarriagesOfTrain() {
		List<Carriage_on_Train__c> carriagesOnTrainJunction = new List<Carriage_on_Train__c> ();
		for (Carriage__c cr : addedCarriages) {
			Carriage_on_Train__c carriageOnTrain = new Carriage_on_Train__c();
			carriageOnTrain.Train__c = trainId;
			carriageOnTrain.Carriage__c = cr.Id;
			carriagesOnTrainJunction.add(carriageOnTrain);
		}
		insert carriagesOnTrainJunction; 		
		
		Train_on_Route__c trainOnRouteJunction = new Train_on_Route__c();
		trainOnRouteJunction.Route__c = routeId;
		trainOnRouteJunction.Train__c = trainId;

		Platform_Of_Route__c lastPlatformOfRoute = [SELECT Departure_Time__c FROM Platform_Of_Route__c WHERE Route__c = :routeId order by Departure_Time__c desc limit 1 ];
		trainOnRouteJunction.Occupied_Until__c = lastPlatformOfRoute.Departure_Time__c;		
		insert trainOnRouteJunction;
		
		disabledTrainList = false;
		return Page.newRoute;
	}
}