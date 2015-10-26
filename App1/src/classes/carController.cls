public with sharing class carController {
	public String inputName {get; set;}
	public String  inputSerial {get; set;}
	public String  inputWeight {get; set;}
	public String editCarName {get; set;}
	public ID selectedId {get; set{selectedId = value;}}
	public ID wheelId {get; set{wheelId = value;}}
	public String lrWheel {get; set;}
	public String fbWheel {get; set;}
	public String newWheelName {get; set;}
	public String newCarName {get; set;}
	
	public List<Wheel__c> wheels;
	Car__c newCar = new Car__c();
	List<Car__c> carsList;
	Wheel__c wheel = new Wheel__c();
	
	public List<Car__c> getCarsList() {
		carsList =  [SELECT Name, id FROM Car__c];
		return carsList;	
	} 
	
	public List<Wheel__c> getWheels() {
		System.debug(selectedId);
		wheels = [SELECT Name, Back__c, Front__c, Left__c, Right__c FROM Wheel__c WHERE  WheelCar__c = :selectedId];
		return wheels;
	}
	
	public PageReference addCar() {		
		Car__C newCar = new Car__c();
		newCar.name = inputName;
		newCar.Serial__c = inputSerial;
		newCar.Weight__c = Integer.valueOf(inputWeight);
		insert newCar;
		PageReference carsList = Page.Cars;
		return carsList;
	}
	
	public PageReference editNamePage() {
		Car__C newCar = new Car__c();
		newCar = [SELECT name, id FROM Car__c WHERE id = :selectedId];
		newCar.name = NewCarName;
		update newCar;
		PageReference cos = Page.Cars;
		return cos;	
	}
	
	public PageReference carDetails() {
		// 1
		PageReference carDetails = Page.CarDetails;
		//carDetails.getParameters().get('id');
		//carDetails.setRedirect(true);		
		System.debug(selectedId);
		// 2
		//PageReferemce carDetails = new PageReference('/apex/CarDetails?id=' + this.selectedId);
		//carDetails.setRedirect(true);
		//String id = ApexPages.currentPage().getParameter('id')
		//this.selectedId
		return carDetails;
	}
	
	public PageReference deleteWheel() {
		wheel = [SELECT name, id FROM Wheel__c WHERE id = :wheelId ];
		delete wheel;
		PageReference carDetails = Page.CarDetails;
		return carDetails;
	
	}
	
	public PageReference addNewWheel() {
		
		Wheel__c newWheel = new Wheel__c();
		String addErrorString = '';
		PageReference outPage = Page.CarDetails;
		
		newWheel.Name = newWheelName;
		if(fbWheel == 'Front') newWheel.Front__c = true;
		else if(fbWheel == 'Back') newWheel.Back__c = true;
		if(lrWheel == 'Left') newWheel.Left__c = true;
		else if(lrWheel == 'Right') newWheel.Right__c = true;
	
		List<Wheel__c> tempList = [Select id from Wheel__c where
			Front__c = :newWheel.Front__c AND Back__c = :newWheel.Back__c AND  
			Left__c = :newWheel.Left__c AND  Right__c = :newWheel.Right__c ];
		if( !tempList.isEmpty() ) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Such wheel already exists!'));
			outPage = Page.newWheel;
		}
		else {
			outPage = Page.CarDetails;
			newWheel.WheelCar__c = selectedId;
			insert newWheel;
		}
		
		return outPage;
	}
	
	public PageReference addNewWheelPage() {
		PageReference outPage = Page.newWheel;
		return outPage;
	}
	public PageReference editName() {
		PageReference outPage = Page.EditCar;
		return outPage;
	}
	
}