public with sharing class CarriageCtrl {
	public List<Seat__c> seatsInCarriage { get; set; }
	public Integer numberOfSeats { get; set; }
	public Boolean bicyclesTransport { get; set; }
	public Boolean disabledSupport { get; set; }
	public Boolean isWithTables { get; set; }
	public Carriage__c carriage {get; set; }
	public Boolean rerender { get; set; }
	public CarriageCtrl() {
		this.carriage = new Carriage__c();
		rerender = true;
	}
	
	public List<Carriage__c> getCarriages() {
		List<Carriage__c> carriages = [SELECT Id, Name, Bicycles_Transport__c, Disabled_People_Support__c, Class__c, Number_Of_Seats__c, Carriage_With_Tables__c FROM Carriage__c];
		return carriages;
	}
	
	public PageReference addCarriageAndUpdateList() {
		Carriage__c newCarriage = new Carriage__c(Bicycles_Transport__c = bicyclesTransport,
											   Disabled_People_Support__c = disabledSupport,
											   Carriage_With_Tables__c = isWithTables,
											   Class__c = carriage.Class__c,
											   Number_Of_Seats__c = carriage.Number_Of_Seats__c);
		insert newCarriage;
		if (carriage.Class__c!='Buffet Car')
			addSeatsToCarriage(newCarriage.Id);		
		PageReference carriagesPage = Page.Carriages;
		return carriagesPage;
	}
	
	public void addSeatsToCarriage(Id carriageId) {
		List<Seat__c> carriageSeats = new List<Seat__c>();
		Carriage__c carriageWithNewSeat = [SELECT Id, Carriage_With_Tables__c, Number_Of_Seats__c FROM Carriage__c WHERE Id = :carriageId];
		numberOfSeats = Integer.valueOf(carriageWithNewSeat.Number_Of_Seats__c);
		for (Integer n=1;n<=numberOfSeats;n++) {
		Seat__c newSeat = new Seat__c();
			newSeat.Name = String.valueOf(n);
			newSeat.IsTaken = false;
			newSeat.Carriage__c = carriageId;
			newSeat.Has_Table__c = false;
			if (math.mod(n, 2)==0) {
				newSeat.Near_Window__c = false;
			}
			else {
				newSeat.Near_Window__c = true;
			}
			if (carriageWithNewSeat.Carriage_With_Tables__c == true) {
				if (n<=(numberOfSeats/2)) {
					newSeat.Has_Table__c = true;
				}
			}
			carriageSeats.add(newSeat);
		}
		if (carriageSeats.size()>0)
			insert carriageSeats;
	}
	
	public PageReference newCarriagePage() {
		PageReference newCarriagePage = Page.newCarriage;
		return newCarriagePage;
	}
	public PageReference carriagesPage() {
		PageReference carriagesPage = Page.Carriages;
		return carriagesPage;
	}
	
	public PageReference backToAdministratorOptions() {
		PageReference outPage = Page.OptionForAdministrator;
		return outPage;
	}
	
	public void hideAdditionalSection() {
		if (carriage.Class__c=='Buffet Car') {
			rerender = false;
		}
		else {
			rerender = true;
		}
	}
}