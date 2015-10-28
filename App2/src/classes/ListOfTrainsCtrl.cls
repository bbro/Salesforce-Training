public with sharing class ListOfTrainsCtrl {
	
	public List<Train__c> trainsList;
	public ID trainId {get; set{trainId = value;}}
	public String newTrainName {get; set;}
	public String newTrainAverageVelocity {get; set;}
	public Train__c train {get; set;}
	public Train__c AllowPackagesCheckbox {get; set;}
	public Boolean pack {get; set;}
	
	public ListOfTrainsCtrl() {
		this.train = new Train__c();
	}
	
	public List<Train__c> getTrainsList() {
		trainsList =  [SELECT Name, id, Type__c, Average_Velocity__c, Allow_Packages__c  FROM Train__c];
		return trainsList;	
	}
	
	public PageReference addTrain() {
		if (trainId == null) {
			Train__c newTrain = new Train__c();
			String typeTrain = train.Type__c;
			newTrain.name = newTrainName;
			newTrain.Type__c = typeTrain;
			newTrain.Average_Velocity__c = Integer.valueOf(newTrainAverageVelocity);
			newTrain.Allow_Packages__c = pack;
			insert newTrain; 
		} else {
			Train__c editTrain = new Train__c();
			editTrain = [SELECT id, name, Type__c, Average_Velocity__c, Allow_Packages__c FROM Train__c WHERE id=:trainId ];
			String typeTrain = train.Type__c;
			editTrain.name = newTrainName;
			editTrain.Type__c = typeTrain;
			editTrain.Average_Velocity__c = Integer.valueOf(newTrainAverageVelocity);
			editTrain.Allow_Packages__c = pack;
			update editTrain;
		}
		PageReference outPage1 = Page.ListOfTrains;
		return outPage1;
	}
		
	public PageReference showAddTrainPage() {
		PageReference outPage2 = Page.NewTrain;
		return outPage2;
	}
	
	public PageReference editTrain() {
		Train__c trainToEdit = new Train__c();
		trainToEdit = [SELECT id, name, Type__c, Average_Velocity__c, Allow_Packages__c FROM Train__c WHERE id=:trainId];
		newTrainName = trainToEdit.name;
		newTrainAverageVelocity = String.valueOf(trainToEdit.Average_Velocity__c);
		train.Type__c = trainToEdit.Type__c;
		pack = trainToEdit.Allow_Packages__c;
		PageReference outPage3 = Page.NewTrain;
		return outPage3;
	}
	
	public PageReference deleteTrain() {
		Train__c trainToDelete = new Train__c();
		trainToDelete = [SELECT id FROM Train__c WHERE id=:trainId];
		delete trainToDelete;
		PageReference outPage4 = Page.ListOfTrains;
		return outPage4;
	}
	
	public PageReference showListOfTrains() {
		PageReference outPage5 = Page.ListOfTrains;
		//PageReference outPage5 = new PageReference('/apex/ListOfTrains');
		outPage5.setRedirect(true);
		return outPage5;
	}
}