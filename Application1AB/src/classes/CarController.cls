public class CarController {
	
	public List<Car__c> cars{ get; set; }
	
	public String nName { get; set; }
	public Integer nWeight { get; set; }
	public String nSerial { get; set; }
	public Id nONameId { get; set{ nONameId = value; }   }
	public Id wheelToDelId { get; set{ wheelToDelId = value; } }
	private String nOName;
	public String nNName { get; set; }
	
	public Boolean nFront { get; set; }
	public Boolean nBack { get; set; }
	public Boolean nLeft { get; set; }
	public Boolean nRight { get; set; }
	public String nWName { get; set; }
	public String fbWheel { get; set; }
	public String lrWheel { get; set; }
	
	public CarController(){	
		cars = [SELECT Name, Serial__c, Weight__c FROM Car__c];
	}
	
	public PageReference nCar(){
		Car__c newcar = new Car__c();
		newcar.Name = nName;
		newcar.Serial__c = nSerial;
		newcar.Weight__c = nWeight;
		insert(newcar);
		cars.add(newcar);
		return null;
	}
	
	public String getNOName(){
		Car__c c = [SELECT Name, Serial__c, Weight__c FROM Car__c WHERE Id = :nONameId];
		this.nOName = c.Name;
		return nOName;
	}
	
	public List<Wheel__c> getWheels() {
		List<Wheel__c> wheels = [SELECT Name, Front__c, Back__c, Left__c, Right__c FROM Wheel__c WHERE CarWheel__r.Id = :nONameId];
		return wheels;
	}

	public PageReference eCar(){
		PageReference pageRef = new PageReference('/apex/EditCar');
        return pageRef;
	}
	
	public PageReference dCar(){
		PageReference pageRef = new PageReference('/apex/CarDetails');
        return pageRef;
	}
	
	public PageReference refresh(){
		PageReference pageRef = new PageReference('/apex/Cars');
        return pageRef;
	}
	
	public PageReference gotoNewWheel(){
		PageReference pageRef = new PageReference('/apex/NewWheel');
        return pageRef;
	}
	
	public PageReference nNCar(){
		Car__c newcar = [SELECT Name, Serial__c, Weight__c FROM Car__c WHERE Name = :nOName];
		integer i = 0, s = cars.size();
		for(; i < s; i++) {
			if(cars.get(i).Name == newcar.Name) {
				break;	
			}
		}
		newcar.Name = nNName;
		upsert(newcar);		
		
		if (i != s) {
			cars.get(i).Name = nNName;
		}		
        return null;
	}
	
	public PageReference wCar(){
		PageReference pageRef = new PageReference('/apex/CarDetails');
        return pageRef;
	}
	
	public PageReference newWheel(){
		
		Wheel__c newW = new Wheel__c();
		
		if(fbWheel == 'Front') newW.Front__c = true;
		else if(fbWheel == 'Back') newW.Back__c = true;
		if(lrWheel == 'Left') newW.Left__c = true;
 		else if(lrWheel == 'Right') newW.Right__c = true;

		newW.Name = nWName;
		newW.CarWheel__c = nONameId;
		
		PageReference pr = null;
		
		if ([SELECT Front__c, Back__c, Left__c, Right__c FROM Wheel__c WHERE CarWheel__r.Id = :nONameId AND Front__c = :newW.Front__c AND Back__c = :newW.Back__c AND Left__c = :newW.Left__c AND Right__c = :newW.Right__c].size() > 0){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Such wheel already exists!'));	
		}
		else{
			insert newW;
			pr = new PageReference('/apex/CarDetails');
		}
		return pr;
	}
	
	public PageReference deleteWheel(){
		Wheel__c delW = [SELECT Id FROM Wheel__c WHERE Id = :wheelToDelId];
		delete delW;
		PageReference showDetailsPage = new PageReference('/apex/CarDetails');
		return showDetailsPage;
	}
}