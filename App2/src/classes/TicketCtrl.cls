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
	public Ticket__c ticket { get; public set; }
	public Carriage__c carriage { get; public set; }
	public Boolean isTable { get; public set; }
	public Boolean isWindow { get; public set; }
	List<Seat_Reservation_on_Route__c> seatReservationOnRouteList;
	List<String> ticketsList { get; set; }
	
	List<String> firstNameTicket = new List<String>();
	List<String> lastNameTicket = new List<String>();
	List<Integer> pinTicket = new List<Integer>();
	List<String> emailTicket = new List<String>();
	List<String> discountTicket = new List<String>();
	List<String> classTicket = new List<String>();
	List<Boolean> windowTicket = new List<Boolean>();
	List<Boolean> nearTableTicket = new List<Boolean>();
		
	public TicketCtrl() {
		ticket = new Ticket__c();
		carriage = new Carriage__c();
		ticketsList = new List<String>();
	}
	
    public PageReference buyTickets() {
    	
    	for(Integer i = 0; i < windowTicket.size(); i++) {
    		
    		City__c cityFromId  = [SELECT id FROM City__c Limit 1];
    		City__c cityToId  = [SELECT id FROM City__c Limit 1];
    		Carriage__c carriageId  = [SELECT id FROM Carriage__c Limit 1];
    		
    		Ticket__c newTicket = new Ticket__c();
	    	newTicket.name = 'ticket2';
	    	newTicket.From__c = cityFromId.Id;
	    	newTicket.To__c = cityToId.Id;
	    	newTicket.Discount__c = ticket.Discount__c;
	    	
	    	Passenger__c pass = new Passenger__c();
	    	pass.Name = firstNameTicket.get(i);
	    	pass.Last_Name__c = lastNameTicket.get(i);
	    	pass.Email__c = emailTicket.get(i);
	    	pass.PIN__c = pinTicket.get(i);
	    	
	    	if(isInvoiceNeed) {
		    	pass.Company_Name__c = businessName;
		    	pass.NIP__c = nip;
		    	pass.Postal_Code__c = postalCode;
		    	pass.Street__c = street;
	    	}
	    	
	    	if(isInvoiceNeed) {
	    		pass.Company_Name__c = businessName;
	    		pass.NIP__c = nip;
	    		pass.Street__c = street;
	    		pass.City__c = city;
	    		pass.Postal_Code__c = postalCode;
	    	}
	    	
	    	Carriage__c newCarriage = new Carriage__c();
	    	newCarriage.Class__c = classTicket.get(i);
	    	newCarriage.Name = 'carriage';
	    	
	    	Seat__c seat = new Seat__c();
	    	seat.Carriage__c = carriageId.Id;
	    	seat.Near_Window__c = windowTicket.get(i);
	    	seat.Has_Table__c =  nearTableTicket.get(i);
	    	
	    	try {
	    		insert pass;
	    		insert newTicket;
	    		insert newCarriage;
	    		insert seat;
	    		
	    	} catch(DmlException e) {
	    		system.debug(e.getMessage());
	    	}
    	}
    return Page.TicketPdfInvoice;
    }
      public PageReference addElementToTicket() {
      	firstNameTicket.add(firstName);
      	lastNameTicket.add(lastName);
      	emailTicket.add(email);
      	pinTicket.add(pin);
      	discountTicket.add(ticket.Discount__c);
		classTicket.add(carriage.Class__c);
		windowTicket.add(isWindow);
		nearTableTicket.add(isTable);
  	
      	Integer j = windowTicket.size() - 1;
		String seatPlace;
		if( windowTicket.get(j) == true ) {
  		seatPlace = 'NEAR WINDOW';
      	} else {
      		seatPlace = 'CORRIDOR';
      	}
  	
		ticketsList.add( 'First Name ' + firstNameTicket.get(j) + ', ' + 'Last Name ' + lastNameTicket.get(j) + ', '
		+ 'Email ' + emailTicket.get(j) + ', ' + 'PIN ' + pinTicket.get(j) + ', '
		+ 'Discount ' + discountTicket.get(j) + ', ' + 'Class ' + classTicket.get(j) + ', ' 
		+ 'Seat Spot ' + seatPlace + ', ' + 'Near Table ' + nearTableTicket.get(j) );
      	
      	return null;
      }
      
      public List<String> getTicketsList() {
		return ticketsList;
	}
	
    public PageReference moveToSearchStationPage() {
    	return null;
    }
	
	public PageReference deleteTicket() {
	return null;
	}
}