public with sharing class CarsController {

    List<Car__c> cars;
    List<Wheel__c> wheels;
    public Car__c car{  get; set; }
    public Wheel__c wheel{  get; set; }
    public String recordId{  get; set; }
    public String recordName{  get; set; }
    public String singleCar{  get; set; }
    
    public String wheelName{  get; set; }
    
    String NewWheelsFrontbackSelect = 'FRONT';
    String newWheelsSideRecord = 'LEFT';
         
    public PageReference addWheel() {
    	Boolean front= false, back= false, left= false, right = false;
    	
    	if(getNewWheelsFrontbackSelect() == 'front') {
    		front = true;
    	}
    	if(getNewWheelsFrontbackSelect()== 'back') {
    		back = true;
    	}
    	if( getNewWheelsSideRecord()== 'left') {
    		left = true;
    	}
    	if(getNewWheelsSideRecord()== 'right') {
    		right = true;
    	}
    	
    	Wheel__c newWheel = new Wheel__c (name=wheelName);
    	newWheel.Front__c = front;
    	newWheel.Back__c = back;
    	newWheel.Left__c = left;
    	newWheel.Right__c = right;
    	newWheel.Car__c = recordId;
    	
    	List<Wheel__c> wheelsTest = [SELECT id from Wheel__c WHERE front__c =:front AND Back__c=:back AND right__c=:right AND left__c=:left AND Car__c=:recordId];
    	
    	if(wheelsTest.size() > 0) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'nie można dodac kola na juz istniejace!'));
    		return null;
    	} else {
    	
    	try {
    	insert newWheel;
    	} catch(DmlException e) {
    		system.debug(e.getMessage());
    	}
    	return moveToDetailsPage();
    	}
        
    }
                
    public List<SelectOption> getFrontBack() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('FRONT','front')); 
        options.add(new SelectOption('BACK','back'));
        return options; 
    }
    
    public List<SelectOption> getLeftRight() {
        List<SelectOption> options2 = new List<SelectOption>();        
        options2.add(new SelectOption('LEFT','left')); 
        options2.add(new SelectOption('RIGHT','right')); 
        return options2; 
    }
           
    public String getNewWheelsFrontbackSelect() {
        return NewWheelsFrontbackSelect;
    }
    
    public String getNewWheelsSideRecord() {
        return newWheelsSideRecord;
    }
                   
    public void setNewWheelsFrontbackSelect(String newWheelsFrontbackSelect) { this.newWheelsFrontbackSelect = newWheelsFrontbackSelect; }
    
    public void setNewWheelsSideRecord(String newWheelsSideRecord) { this.newWheelsSideRecord = newWheelsSideRecord; }
    
    public Id wheelRecordId{  
    	get;
    	set {
    		wheelRecordId = value;
    	} 
    }
    
    public CarsController() {
        cars = [SELECT id, name FROM Car__c];
    }
    
    public List<Car__c> getCars(){
        return cars;
    }
    
    public List<Wheel__c> getWheels(){
    	wheels = [SELECT id, name, front__c, back__c, left__c, right__c  FROM Wheel__c WHERE Car__r.name=:recordName];
    	
        return wheels;
    }
    
    public PageReference saveEditedField() {
    	
    	 car = [SELECT id FROM CAR__c WHERE Id=:recordId];
    	 car.name = singleCar;
    	 
    	 try{
    	 	update car;
    	 } catch (DmlException e){
    	 	system.debug(e.getmessage());
    	 }
    	 return moveToList();
    }
    
    public PageReference deleteWheel() {
    	
    	 Wheel__c wheelToDelete = [SELECT id, name, front__c, back__c, left__c, right__c  FROM Wheel__c WHERE id=:wheelRecordId];
    	// try{
    	 	delete wheelToDelete;
    	/* } catch (DmlException e){
    	 	system.debug(e.getmessage());
    	 }
    	 */
    	 return moveToDetailsPage();
    }
    
    public pageReference moveToList() {
    	PageReference listPage = Page.Cars;//new PageReference('/apex/Cars');
		    listPage.setRedirect(true);
    return listPage;
    }
    
    public pageReference moveToDetailsPage() {
	    PageReference detailsPage = Page.CarsDetails;//new PageReference('/apex/CarsDetails' + recordId);
	    //currentPage.setRedirect(true);
    return detailsPage;
    }
    
    public pageReference moveToEditPage() {
    	Car__c car = [SELECT name FROM Car__c WHERE id=:recordId];
    	singleCar = car.name;
	    PageReference currentPage = Page.CarEditName;
    return currentPage;
    }
    
    public pageReference moveToAddNewCarRecord() {
	    PageReference currentPage = new PageReference('/apex/AddNewCarRecord');
	    //currentPage.setRedirect(true);
    return currentPage;
    }
    
    public pageReference moveToAddNewWheelRecord() {
	    PageReference currentPage = Page.NewWheel;
    return currentPage;
    }
}