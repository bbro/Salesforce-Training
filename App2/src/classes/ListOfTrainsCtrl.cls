public with sharing class ListOfTrainsCtrl {
  
  public List<Train__c> trainsList;
  public ID trainId {get; set{trainId = value;}}
  public String newTrainName {get; set;}
  public String newTrainAverageVelocity {get; set;}
  public Train__c train {get; set;}
  public Train__c AllowPackagesCheckbox {get; set;}
  public Boolean pack {get; set;}
  public String inputTextErrorMessage {get; set;}
  
  
  public ListOfTrainsCtrl() {
    this.train = new Train__c();
  }
  
  public List<Train__c> getTrainsList() {
    trainsList =  [SELECT Name, id, Type__c, Average_Velocity__c, Allow_Packages__c  FROM Train__c];
    return trainsList;  
  }
  
  public PageReference addTrain() {
  	
    if (trainId == null)  {
      Train__c newTrain = new Train__c();
      String typeTrain = train.Type__c;  
      if (newTrainName == null || !newTrainName.isAlphaNumeric()) {
      	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Name must have value and no special characters'));
        PageReference outPage = Page.NewTrain;
        return outPage;
      } else {
      	newTrain.name = newTrainName;
      }
      if ((!newTrainAverageVelocity.isNumeric() || 0 > Integer.valueOf(newTrainAverageVelocity)) || (Integer.valueOf(newTrainAverageVelocity) > 1000 )) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Velocity must be greater than 0 and less than 1000'));
        PageReference outPage = Page.NewTrain;
        return outPage;
      } else {
      	newTrain.Average_Velocity__c = Integer.valueOf(newTrainAverageVelocity);
      }
      newTrain.Type__c = typeTrain;
      newTrain.Allow_Packages__c = pack; 
      insert newTrain;     
         
    } else {
      Train__c editTrain = new Train__c();
      editTrain = [SELECT id, name, Type__c, Average_Velocity__c, Allow_Packages__c FROM Train__c WHERE id=:trainId ];
      String typeTrain = train.Type__c;
      if (newTrainName == null || !newTrainName.isAlphaNumeric()) {
      	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Name must have value and no special characters'));
        PageReference outPage = Page.NewTrain;
        return outPage;
      } else {
      	editTrain.name = newTrainName;
      }
      if ((!newTrainAverageVelocity.isNumeric() || 0 > Integer.valueOf(newTrainAverageVelocity)) || (Integer.valueOf(newTrainAverageVelocity) > 1000 )) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Velocity must be greater than 0 and less than 1000'));
        PageReference outPage = Page.NewTrain;
        return outPage;
      } else {
      	editTrain.Average_Velocity__c = Integer.valueOf(newTrainAverageVelocity);
      }
      editTrain.Type__c = typeTrain;
      editTrain.Allow_Packages__c = pack; 
      update editTrain;   

      }
      PageReference outPage = Page.ListOfTrains;
      return outPage;  
  }
  							
  public PageReference showAddTrainPage() {
    PageReference outPage = Page.NewTrain;
    return outPage;
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