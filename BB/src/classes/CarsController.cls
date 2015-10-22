public class CarsController {

	public Car__c c {get;
		set {
			c = value;
		}
	}
	
	public Wheel__c w{get;
		set {
			w = value;		
		}
	}
	public List<Car__c> cars {get;set;}
	public String addErrorString {get;set;}
	public String fbWheel {get;set;}
	public String lrWheel {get;set;}
	
	
	public CarsController() {
		c = new Car__c();
		w = new Wheel__c();
		fbWheel = 'Front';
		lrWheel = 'Left';
		cars = [SELECT Id, Name, Serial__c, Weight__c FROM Car__c];
	}

	public List<Wheel__c> getWheels() {
		List<Wheel__c> wheels = [Select Id, Name, Back__c, Front__c, Left__c, Right__c from Wheel__c where RelName__c = :c.Id];
		return wheels;
	}
	public PageReference saveNewCar() {
		if(!String.isEmpty(c.Name) && !String.isEmpty(c.Serial__c) && c.Weight__c.toPlainString().isNumeric()) {
			cars.add(c);
			addErrorString = '';
			insert c;
			c = new Car__c();
			return Page.Cars;
		}
		else {
			addErrorString = 'ERROR';
			return null;
		}
	}
	public PageReference deleteWheel() {
		delete w;
		w = new Wheel__c();
		return Page.CarDetails;
	}
	public PageReference saveNewWheel() {
		Wheel__c newWheel = w;
		addErrorString = '';
		PageReference outPage = Page.CarDetails;
		
		if(fbWheel == 'Front') newWheel.Front__c = true;
		else if(fbWheel == 'Back') newWheel.Back__c = true;
		if(lrWheel == 'Left') newWheel.Left__c = true;
		else if(lrWheel == 'Right') newWheel.Right__c = true;
		
		system.debug(w.Left__c);
		system.debug(w.Back__c);
		system.debug(w.Front__c);
		system.debug(w.Right__c);
		List<Wheel__c> tempList = [Select id from Wheel__c where
			Front__c = :newWheel.Front__c AND Back__c = :newWheel.Back__c AND  
			Left__c = :newWheel.Left__c AND  Right__c = :newWheel.Right__c ];
		if( !tempList.isEmpty() ) {
			addErrorString = 'Wheel exists';
			outPage = Page.AddNewWheel;
			w = new Wheel__c();
			newWheel = new Wheel__c();
		}
		else {
			outPage = Page.CarDetails;
			newWheel.RelName__c = c.Id;
			insert newWheel;
		}
		
		return outPage;
	}
	
	public PageReference cancelAdd() {
		addErrorString = '';
		return Page.CarDetails;
	}
	public PageReference cancelDetails() {
		return Page.Cars;
	}
	
	public PageReference gotoEditCar() {
		List<Car__c> tempCars = [Select Id, Name, Serial__c, Weight__c from Car__c where Id = :c.Id];
		c = tempCars[0];
		return Page.EditCar;
	}
	
	public PageReference gotoCarDetail() {
		List<Car__c> tempCars = [Select Id, Name, Serial__c, Weight__c from Car__c where Id = :c.Id];
		c = tempCars[0];
		return Page.CarDetails;
	}
	
	public PageReference updateCar() {
		update c;
		cars = [SELECT Id, Name, Serial__c, Weight__c FROM Car__c];
				
		return Page.Cars;
	}
	
	public PageReference gotoAddNewCar() {
		return Page.NewCar;
	}
	public PageReference gotoAddNewWheel() {
		w = new Wheel__c();
		return Page.AddNewWheel;
	}

}