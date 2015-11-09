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
		trainsOptionList = new List<SelectOption> ();
	}
	
	// get all trains
	public List<Train__c> getTrains() {
		List<Train__c> trains = new List<Train__c> ();
		trains = [SELECT Id, Name, Type__c FROM Train__c];	
		return trains;
	}
	
	// get all trains ids after occupied time
	public Set<Train__c> getAvailableTrains() {
		List<Platform_Of_Route__c> platformsOnRoute = [SELECT Arrival_Time__c FROM Platform_Of_Route__c WHERE Route__c = :routeId order by Arrival_Time__c];
		List<Id> trainsIds = new List<Id> ();
		List<Train_on_Route__c> trainsAvailableOnTime = new List<Train_on_Route__c> ();
		Set<Train__c> trains = new Set<Train__c> ();
		for (Train_on_Route__c trOnRt : [SELECT Train__c FROM Train_on_Route__c]) {
			trainsIds.add(trOnRt.Train__c);
		} 
		if (trainsIds.size() == 0) {
			trains = new Set<Train__c> ([SELECT Id, Name, Type__c from Train__c]);
		}
		else {
			trainsAvailableOnTime = [SELECT Train__c, Train__r.Id, Train__r.Name, Train__r.Type__c FROM Train_on_Route__c WHERE ( Occupied_Until__c < :platformsOnRoute[0].Arrival_Time__c) ];
			
			for (Train_on_Route__c tr : trainsAvailableOnTime) {
				trains.add(tr.Train__r);
			}
			for (Train__c tr : [SELECT Id, Name, Type__c FROM Train__c WHERE Id not in :trainsIds]) {
				trains.add(tr);
			}
		}
		return trains;
	}

	// create select option list of trains
	public List<SelectOption> getTrainOptions() {
		List<Platform_of_Route__c> platforms = [SELECT Id, Platform__r.Station__r.Is_Main_Station__c FROM Platform_of_Route__c WHERE Platform__r.Station__r.Is_Main_Station__c = false AND Route__c = :routeId];
		for (Train__c tr : getAvailableTrains()) {
			if (platforms.size() > 0 && tr.Type__c == 'InterCity') {
				continue;
			}
			trainsOptionList.add(new SelectOption(tr.Id, tr.Name));
		}
		return trainsOptionList;
	}
	
	// get all available carriages
	public List<Carriage__c> getAvailableCarriages() {
		List<Id> availableCarriagesIds = new List<Id> ();
		for (Carriage_on_Train__c cr : [SELECT Carriage__c FROM Carriage_on_Train__c WHERE Train__c IN :getAvailableTrains()]) {
			availableCarriagesIds.add(cr.Id);
		}
		List<Carriage__c> carriagesToAdd = new List<Carriage__c> (); 
		
		List<Carriage_on_Train__c> allCarriagesOnTrains = [SELECT Carriage__c FROM Carriage_on_Train__c];
		List<Id> allCarriagesIds = new List<Id> ();
		for (Carriage_on_Train__c c : allCarriagesOnTrains) {
			allCarriagesIds.add(c.Carriage__c);
		}
		
		if (availableCarriagesIds.size() == 0) {
			carriagesToAdd = [SELECT Id FROM Carriage__c WHERE Id not in :allCarriagesIds ];
		} else {
			for (Carriage__c cr : [SELECT Id FROM Carriage__c WHERE Id in :availableCarriagesIds]) {
				carriagesToAdd.add(cr); 
			}
			for (Carriage__c cr : [SELECT Id, Name FROM Carriage__c WHERE Id not in :availableCarriagesIds]) {
				carriagesToAdd.add(cr);
			}
		}
		List<Carriage__c> carriages = new List<Carriage__c> ();
		carriages = [SELECT Id, Name, Number_Of_Seats__c, Bicycles_Transport__c, Class__c,
							Carriage_With_Tables__c, Disabled_People_Support__c 
					 FROM Carriage__c 
					 WHERE Id IN :carriagesToAdd];	
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