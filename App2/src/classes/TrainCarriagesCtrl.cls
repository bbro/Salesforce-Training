public class TrainCarriagesCtrl {
	public Id trainId {get;set;}
	public Id carriageId {get;set;}
	public List<Carriage__c> addedCarriages {get;set;}
	
	public TrainCarriagesCtrl() {
		addedCarriages = new List<Carriage__c> ();
	}
	
	public List<Train__c> getTrains() {
		List<Train__c> trains = new List<Train__c> ();
		trains = [SELECT Id, Name, Type__c FROM Train__c];	
		return trains;
	}
	
	public List<Carriage__c> getCarriages() {
		List<Carriage__c> carriages = new List<Carriage__c> ();
		carriages = [SELECT Id, Name, Number_Of_Seats__c, Bicycles_Transport__c, Class__c, 
			Carriage_With_Tables__c, Disabled_People_Support__c FROM Carriage__c];	
		return carriages;
	}
	
	public Carriage__c getCarriageById(Id crId) {
		Carriage__c carriages = new Carriage__c ();
		carriages = [SELECT Id, Name, Number_Of_Seats__c, Bicycles_Transport__c, Class__c, 
			Carriage_With_Tables__c, Disabled_People_Support__c FROM Carriage__c WHERE Id = :crId];	
		return carriages;
	}
	
	public List<SelectOption> getTrainOptions() {
		List<SelectOption> trainOptions = new List<SelectOption> ();
		for (Train__c tr : getTrains()) {
			trainOptions.add(new SelectOption(tr.Id, tr.Name));
		}
		return trainOptions;
	}
	
	public List<SelectOption> getCarriageOptions() {
		List<SelectOption> carriageOptions = new List<SelectOption> ();
		for (Carriage__c cr : getCarriages()) {
			carriageOptions.add(new SelectOption(cr.Id, cr.Name + '; class:'+cr.Class__c + '; seats:' + cr.Number_Of_Seats__c ));
		}
		return carriageOptions;
	}
	
	public PageReference addCarriageToList() {
		
		Carriage__c c = new Carriage__c();
		c = getCarriageById(carriageId);
		addedCarriages.add(c);
		return null;
	}
	
	public PageReference saveCarriagesOfTrain() {
		List<Carriage_on_Train__c> carriagesOnTrainJunction = new List<Carriage_on_Train__c> ();
		for (Carriage__c cr : addedCarriages) {
			Carriage_on_Train__c carriageOnTrain = new Carriage_on_Train__c();
			carriageOnTrain.Train__c = trainId;
			carriageOnTrain.Carriage__c = cr.Id;
			carriagesOnTrainJunction.add(carriageOnTrain);
		}
		insert carriagesOnTrainJunction; 		
		return null;
	}
}