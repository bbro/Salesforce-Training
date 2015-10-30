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
	public List<Seat_Reservation_on_Route__c> seatReservationOnRouteList;
	public List<String> ticketsList { get; set; }
	public List<String> firstNameTicket = new List<String>();
	public List<String> lastNameTicket = new List<String>();
	public List<Integer> pinTicket = new List<Integer>();
	public List<String> emailTicket = new List<String>();
	public List<String> discountTicket = new List<String>();
	public List<String> classTicket = new List<String>();
	public List<Boolean> windowTicket = new List<Boolean>();
	public List<Boolean> nearTableTicket = new List<Boolean>();
	public List<String> invoiceTicket = new List<String>();
    public Double ticketsPrice = 0.0d;
		
	public TicketCtrl() {
		ticket = new Ticket__c();
		carriage = new Carriage__c();
		ticketsList = new List<String>();
		ticketDataList = new List<TicketData>();
	}
	
    public PageReference buyTickets() {
    	for(Integer i = 0; i < windowTicket.size(); i++) {
    		Ticket__c ticketSObject  = [SELECT id, From__c, To__c FROM Ticket__c Limit 1];
    		Carriage__c carriageId  = [SELECT id FROM Carriage__c Limit 1];
    		City__c ticketFrom = [SELECT name from City__c WHERE id=:ticketSObject.From__c];
    		City__c ticketTo = [SELECT name from City__c WHERE id=:ticketSObject.To__c];
    		
    		Ticket__c newTicket = new Ticket__c();
	    	newTicket.name = 'ticket2';
	    	newTicket.From__c = ticketFrom.Id;
	    	newTicket.To__c = ticketTo.Id;
	    	newTicket.Discount__c = discountTicket.get(i);
	    	
	    	Passenger__c pass = new Passenger__c();
	    	pass.Name = firstNameTicket.get(i);
	    	pass.Last_Name__c = lastNameTicket.get(i);
	    	pass.Email__c = emailTicket.get(i);
	    	pass.PIN__c = pinTicket.get(i);
	    	
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
    	prepareTicketAndInvoiceData();
    return Page.TicketPdfPage;
    }
    
    public void prepareTicketAndInvoiceData() {
    	for(Integer i = 0; i < windowTicket.size(); i++) {
    		Ticket__c ticketSObject  = [SELECT id, From__c, To__c FROM Ticket__c Limit 1];
    		Carriage__c carriageId  = [SELECT id FROM Carriage__c Limit 1];
    		City__c ticketFrom = [SELECT name from City__c WHERE id=:ticketSObject.From__c];
    		City__c ticketTo = [SELECT name from City__c WHERE id=:ticketSObject.To__c];
    		
	    	TicketData ticketData = new TicketData(); 
	    	ticketData.fromStation = ticketFrom.Name;
	    	ticketData.toStation = ticketTo.Name;
	    	ticketData.carrierClass = classTicket.get(i);
	    	ticketData.discount = discountTicket.get(i);
	    	ticketData.carriageClass = classTicket.get(i);
	    	ticketData.departueDate = 'DATAAA';
	    	ticketData.carriageClass = classTicket.get(i);
	    	ticketData.carriageClass = classTicket.get(i);
	    	ticketData.seatplace = (windowTicket.get(i) == true) ? 'Window' : 'Corridor';
			ticketData.withTable = (nearTableTicket.get(i) == true) ? 'Yes' : 'No';
			ticketData.pin = pinTicket.get(i);
	    	ticketData.price = calculatePrice(classTicket.get(i), 5.0d, discountTicket.get(i));
	    	ticketDataList.add(ticketData);
    	}
    }
    
    public pageReference invoiceShow() {
    	prepareTicketAndInvoiceData();
    return Page.TicketPdfInvoice;
    }
    
    public Double getTicketsPrice() {
    	return ticketsPrice;
    }
    
    private Double calculatePrice(String carriageClass, Double stations, String discount ) {
		double singleTicketPrice = 0.0d;
		Double classPrice = 0.0d;
		Double myDiscount = 1.0d;
		
		if(carriageClass == '1') {
			classPrice = 50.0d;
		} else if(carriageClass == '2') {
			classPrice = 25.0d;
		} else {
			classPrice = 50.0d;
		}
		
		if(discount == 'Normal') {
			myDiscount = 1.0d;
		} else if(discount == 'Student') {
			myDiscount = 2.0d;
		}
		
		singleTicketPrice = ( classPrice + (stations * 0.2d) ) / myDiscount;
		ticketsPrice += singleTicketPrice;
		
		return singleTicketPrice;
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
	public List<String> getInvoiceTicket() {
		return invoiceTicket;
	}
	
    public PageReference moveToSearchStationPage() {
    	return null;
    }
	
	public PageReference deleteTicket() {
		return null;
	}
	
	public List<TicketData> ticketDataList{GET; SET; }
	
	public class TicketData {
		
		public String fromStation {get; set;}
		public String carrierClass {get; set;}
		public String toStation {get; set;}
		public String discount {get; set;}
		public Double price {get; set;}
		
		public String carriageClass {get; set;}
		public String departueDate {get; set;}
		public String seatplace {get; set;}
		public String withTable {get; set;}
		public Integer pin { get; set; }
	}
}