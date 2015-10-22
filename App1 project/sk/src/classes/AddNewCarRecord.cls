public class AddNewCarRecord {
	public Car__c car{get; set;}
    public String carName{get; set;}
    public Integer weight{get; set;}
    public String serial{get; set;}
	
	public AddNewCarRecord() {
	}
	
	
	public PageReference addCarRecord() {
		if(fieldsNotEmpty()){
			insertRecord();
			return moveToList();
	    } else {
	    	showErrorInfo();
	    	return null;
	    }
    }
    
    private void insertRecord() {
    try {
    	Car__c  newCar = new Car__c(Name=carName, serial__c=serial, weight__c=weight);
    	insert newCar;
	    } catch(DmlException e) {
	    	ApexPages.addMessages(e);
	    	system.debug(e.getMessage());
	    }
    }
    
    private Boolean fieldsNotEmpty() {
	    if(carName.length() > 0){
	    	return true;
	    } else { 
	    	//car.name.addError('Error');
	    return false;
	    }
	    
	    if(serial.length() > 0){
	    	return true;
	    } else {
	    return false;
	    }
    }
    
    public pageReference moveToList() {
    	PageReference listPage = Page.Cars;//('/apex/Cars');
		    //listPage.setRedirect(true);
    return listPage;
    }
    
    public void showErrorInfo() {
	    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Field cant by empty!');
	    ApexPages.addMessage(myMsg);
    }
    
}