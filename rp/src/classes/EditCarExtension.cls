public with sharing class EditCarExtension {
	private carController controller;
	public EditCarExtension(carController controller) {
    	this.controller = controller; 
    }
    public String updatedName { get; set; }
    public Id carToUpdate { 
    	get; 
    	set {
    		carToUpdate = value; 
    	}
    }
    public void updateCarName(Id carId, String updatedCarName)
    {
    	Car__c carWithNewName = [SELECT Name FROM Car__c WHERE Id = :carId];
    	carWithNewName.Name = updatedCarName;
    	update carWithNewName;
    }
    public PageReference updateAndReturn() {
    	updateCarName(carToUpdate, updatedName);
    	PageReference homePage = new PageReference('/apex/Cars');
		return homePage;
    }
}