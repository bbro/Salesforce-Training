public with sharing class carController {
	public String newCarName { get; set; }
	public String newCarWeight { get; set; }
	public String newCarSerial { get; set; }
	private String detailedCarName;
	public String newWheelName { get; set; }
	public Boolean newWheelFront { get; set; }
	public Boolean newWheelBack { get; set; }
	public Boolean newWheelLeft { get; set; }
	public Boolean newWheelRight { get; set; }
	public String newWheelCarName { get; set; }
	
	public Id detailedCarId { 
    	get; 
    	set {
    		detailedCarId = value; 
    	}
    }
    
    public Id wheelToDeleteId { 
    	get; 
    	set {
    		wheelToDeleteId = value; 
    	}
    }
    
	public carController() {}
	public static List<Car__c> getCars() {
		List<Car__c> cars = [SELECT Name, Serial__c, Weight__c FROM Car__c];
		return cars;
	}
	
	public String getDetailedCarName() {
		Car__c detailedCar = [SELECT Name FROM Car__c WHERE Id=:detailedCarId];
		this.detailedCarName = detailedCar.Name;
		return detailedCarName;
	}
	
	public List<Wheel__c> getWheels() {
		List<Wheel__c> wheels = [SELECT Name, Front__c, Back__c, Left__c, Right__c FROM Wheel__c WHERE Car__r.Id=:detailedCarId];
		return wheels;
	}
	
	public PageReference addingNewCar() {
		PageReference addNewCar = new PageReference('/apex/NewCar');
		return addNewCar;
	}
	
	public PageReference saveNewCar() {
		if (newCarName=='' || newCarWeight=='' || newCarSerial=='') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fill in all input fields!'));
			return null;
		}
		else {
			Car__c newCar = new Car__c();
			newCar.Name = newCarName;
			newCar.Weight__c = Integer.ValueOf(newCarWeight);
			newCar.Serial__c = newCarSerial;
			insert newCar;
			PageReference homePage = new PageReference('/apex/Cars');
			return homePage;
		}
	}
	
	public PageReference cancelNewCar() {
		PageReference homePage = new PageReference('/apex/Cars');
		return homePage;
	}
	
	public PageReference editCarName() {
		PageReference editNamePage = new PageReference('/apex/EditCar');
		return editNamePage;
	}
	
	public PageReference showCarDetails() {
		PageReference showDetailsPage = new PageReference('/apex/CarDetails');
		return showDetailsPage;
	}
	
	public PageReference showNewWheelPage() {
		PageReference NewWheelPage = new PageReference('/apex/NewWheel');
		return NewWheelPage;
	}
	
	public PageReference saveNewWheel() {
		PageReference homePage;
		Wheel__c newWheel = new Wheel__c();
		newWheel.Name = newWheelName;
		newWheel.Front__c = newWheelFront;
		newWheel.Back__c = newWheelBack;
		newWheel.Left__c = newWheelLeft;
		newWheel.Right__c = newWheelRight;
		newWheel.Car__c = detailedCarId;
		PageReference goToPage = null;
		if([SELECT Front__c, Back__c, Left__c, Right__c FROM Wheel__c 
				WHERE Car__r.Id = :detailedCarId 
				AND Front__c = :newWheelFront 
				AND Back__c = :newWheelBack
				AND Left__c = :newWheelLeft
				AND Right__c = :newWheelRight].size() > 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Such wheel already exists!'));
		} else {
			insert newWheel;
			goToPage = new PageReference('/apex/CarDetails');
		}
		return goToPage;
	}
	
	public PageReference deleteWheel() {
		Wheel__c wheelToDelete = [SELECT Id FROM Wheel__c WHERE Id = :wheelToDeleteId];
		delete wheelToDelete;
		PageReference showDetailsPage = new PageReference('/apex/CarDetails');
		return showDetailsPage;
	}
	
}