public class TicketCtrl {
    public String firstName { get; public set; }
	public String lastName { get; public set; }
	public Integer pin { get; public set; }
	public String email { get; public set; }
	public Boolean isInvoiceNeed { get; public set; }
	public String businessName { public get; public set; }
	public Integer nip { get; public set; }
	public String postalCode { get; public set; }
	public String city { get; public set; }
	public String street { get; public set; }
	public Integer ticketsNumber { get; public set; }
	public Ticket__c ticket { get; public set; }
	public Carriage__c carriage { get; public set; }
	public Boolean isTable { get; public set; }
	public Boolean isWindow { get; public set; }
	List<Seat_Reservation_on_Route__c> seatReservationOnRouteList;
	List<String> ticketsList { get; set; }
		
	public TicketCtrl() {
		ticket = new Ticket__c();
		carriage = new Carriage__c();
		ticketsList = new List<String>();
	}
	
    public void addTicket() {
    	Ticket__c newTicket = new Ticket__c();
    	newTicket.name = 'ticket2';
    	newTicket.From__c = 'a0T24000000jCImEAM';
    	newTicket.To__c = 'a0T24000000jCL1EAM';
    	newTicket.Discount__c = ticket.Discount__c;
    	
    	Passenger__c pass = new Passenger__c();
    	pass.Name = firstName;
    	pass.Last_Name__c = lastName;
    	pass.Email__c = email;
    	pass.PIN__c = pin;
    	
    	if(isInvoiceNeed) {
    		pass.Company_Name__c = businessName;
    		pass.NIP__c = nip;
    		pass.Street__c = street;
    		pass.City__c = city;
    		pass.Postal_Code__c = postalCode;
    	}
    	
    	Carriage__c newCarriage = new Carriage__c();
    	newCarriage.Class__c = carriage.Class__c;
    	newCarriage.Name = 'carriage';
    	
    	Seat__c seat = new Seat__c();
    	seat.Carriage__c = 'a0C24000004jNMkEAM';
    	seat.Near_Window__c = isWindow;
    	seat.Has_Table__c =  isTable;
    	
    	try {
    		insert pass;
    		insert newTicket;
    		insert newCarriage;
    		insert seat;
    		
    	} catch(DmlException e) {
    		system.debug(e.getMessage());
    	}
    }
    
      public PageReference addElementToTicket() {
      	String seatPlace;
      	if( isWindow == true ) {
      		seatPlace = 'NEAR WINDOW';
      	} else {
      		seatPlace = 'CORRIDOR';
      	}
      	ticketsList.add('DISCOUNT: ' + ticket.Discount__c + ', SEAT: ' + seatPlace);
      	return null;
      }
      
      public List<String> getTicketsList() {
		return ticketsList;
	}
	
    public PageReference moveToSearchStationPage() {
    	return null;
    }
    
    public PageReference buyTicket() {
    	addTicket();
    	return null;
    }
	
	public PageReference deleteTicket() {
	return null;
	}
}