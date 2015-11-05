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
	
	public Carriage__c trainCarriage { get; public set; }
	
	public Boolean isTable { get; public set; }
	public Boolean isWindow { get; public set; }
	public List<Seat_Reservation_on_Route__c> seatReservationOnRouteList;
	public List<String> ticketsList { get; set; }
    public String ticketToDelete {get; set;}
	public List<TicketData> ticketDataList { get; set; }
	
	public Id routeToBuyTicketForId { get;set; }
	public String stationFromName { get; set; }
	public String stationToName { get;set; }
	
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
    Station__c cityFromStation, cityToStation;
   	Seat__c freeSeat;
	Boolean foundSeat = false;
	Platform_Of_Route__c platformOfroute;
	List<Platform_Of_Route__c> allRouteStation;
	
    Train_on_Route__c t;
	List<Carriage_on_Train__c> c;
	List<Seat__c> seatList;
	List<Seat_Reservation_on_Route__c> seatReservationOnRoute;	
	
	public TicketCtrl() {
		saveDataFromFindRoutePage();
		ticket = new Ticket__c();
		trainCarriage = new Carriage__c();
		ticketsList = new List<String>();
		ticketDataList = new List<TicketData>();
		cityFromStation = [SELECT id, name, City__c  FROM Station__c WHERE name =: stationFromName];
    	cityToStation = [SELECT id, name, City__c FROM Station__c WHERE name =: stationToName];
    	platformOfroute = [SELECT Route__c, Departure_Time__c, Arrival_Time__c, Platform__c FROM Platform_Of_Route__c WHERE Route__r.id =: routeToBuyTicketForId AND Platform__r.Station__r.Name = :stationFromName];
    	allRouteStation = [SELECT Station_Number__c, Platform__r.Station__r.Name  FROM Platform_Of_Route__c WHERE Route__r.id = :routeToBuyTicketForId ];
    	t = [SELECT Train__c, Route__c, Route__r.Id FROM Train_on_Route__c WHERE Route__r.Id = :routeToBuyTicketForId];
    	c = [SELECT Carriage__c, Carriage__r.Class__c, Carriage__r.Number_Of_Seats__c,Carriage__r.Carriage_With_Tables__c, Train__c, Train__r.Id FROM Carriage_on_Train__c WHERE Train__r.Id = :t.Train__c];
    	seatList = [SELECT IsTaken__c, Near_Window__c, Has_Table__c, Carriage__r.Id, Name FROM Seat__c];
	}
	
	public void saveDataFromFindRoutePage() {
		routeToBuyTicketForId = ApexPages.currentPage().getParameters().get('routeToBuyTicketForId');
		stationFromName = ApexPages.currentPage().getParameters().get('stationFromName');
		stationToName = ApexPages.currentPage().getParameters().get('stationToName');
	}
	
	public List<Carriage__c> getAdequateCarriages(Integer ticketInListIndex) {
		List<Carriage__c> adequateCarriages = new List <Carriage__c>();
		for (Carriage_on_Train__c currentCarriage : c) {
			if (currentCarriage.Carriage__r.Carriage_With_Tables__c == nearTableTicket.get(ticketInListIndex)) {
				adequateCarriages.add(currentCarriage.Carriage__r);
			}			
		}
		if(adequateCarriages.size() == 0) {
			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'no carriages match spec.');
			ApexPages.addMessage(errorMsg);
			system.debug('no carriages match spec.');
		}
		return adequateCarriages;
	}
	
	Integer ticketInListIndex = 0;
	public PageReference getFreeSeatsList() {
		freeSeat = null;
		for( ticketInListIndex = 0; ticketInListIndex < ticketsList.size(); ticketInListIndex++) {
			for (Carriage__c currentCarriage : getAdequateCarriages(ticketInListIndex)) {
				for (Seat__c singleSeat : seatList) {
					if (singleSeat.Carriage__r.Id == currentCarriage.Id && !singleSeat.IsTaken__c) {
							trainCarriage = currentCarriage;
							singleSeat.IsTaken__c = true;
							freeSeat = singleSeat;
							insertTickets(ticketInListIndex);
						break;
					}
				}
			}
		}
		
    	return Page.TicketPdfPage;
	}
	
    public void insertTickets(Integer ticketInListIndex) {
    	Seat_Reservation_on_Route__c newSeatReservaionOnRoute= new Seat_Reservation_on_Route__c();
		Ticket__c newTicket = new Ticket__c();
    	newTicket.name = cityFromStation.Name + ' ' + cityToStation.Name;
    	newTicket.From__c = cityFromStation.City__c;
    	newTicket.To__c = cityToStation.City__c;
    	newTicket.Discount__c = discountTicket.get(ticketInListIndex);
    	
    	Passenger__c pass = new Passenger__c();
    	pass.Name = firstNameTicket.get(ticketInListIndex);
    	pass.Last_Name__c = lastNameTicket.get(ticketInListIndex);
    	pass.Email__c = emailTicket.get(ticketInListIndex);
    	pass.PIN__c = pinTicket.get(ticketInListIndex);
    	
    	if (isInvoiceNeed) {
    		pass.Company_Name__c = businessName;
    		pass.NIP__c = nip;
    		pass.Street__c = street;
    		pass.City__c = city;
    		pass.Postal_Code__c = postalCode;
    	}
    	
    	freeSeat.isTaken__c = true;    	
    	try {
    		insert newTicket;
    		insert pass;
    		update freeSeat;
    		
    		newSeatReservaionOnRoute.Ticket__c = newTicket.Id;
	    	newSeatReservaionOnRoute.Passenger__c = pass.Id;
	    	newSeatReservaionOnRoute.Seat__c = freeSeat.Id;
    		newSeatReservaionOnRoute.Route__c = t.Route__r.Id;
    	
    		insert newSeatReservaionOnRoute;
    	} catch(DmlException e) {
    		system.debug(e.getMessage());
    	}
		 setTicketAndInvoiceData(ticketInListIndex);   	
    }
    
    public void setTicketAndInvoiceData(Integer ticketInListIndex) {
    	TicketData ticketData = new TicketData(); 
    	ticketData.stationFromName = cityFromStation.Name;
    	ticketData.stationToName = cityToStation.Name;
    	ticketData.carrierClass = classTicket.get(ticketInListIndex);
    	ticketData.discount = discountTicket.get(ticketInListIndex);
    	ticketData.carriageClass = classTicket.get(ticketInListIndex);
    	ticketData.departueDate = String.valueOf(platformOfroute.Departure_Time__c);
    	ticketData.carriageClass = classTicket.get(ticketInListIndex);
    	ticketData.carriageClass = classTicket.get(ticketInListIndex);
    	ticketData.seatplace = (windowTicket.get(ticketInListIndex) == true) ? 'Window' : 'Corridor';
		ticketData.withTable = (nearTableTicket.get(ticketInListIndex) == true) ? 'Yes' : 'No';
		ticketData.pin = pinTicket.get(ticketInListIndex);
    	ticketData.price = calculatePrice(classTicket.get(ticketInListIndex), getNumberOfStationTraveled(), discountTicket.get(ticketInListIndex));
    	ticketDataList.add(ticketData);
    }
    
    public Decimal getNumberOfStationTraveled() {
    	Platform_Of_Route__c startStation;
    	Platform_Of_Route__c stopStation;
    	
    	for (Platform_Of_Route__c platformOfRoute : allRouteStation) {
    		if (platformOfRoute.Platform__r.Station__r.Name == stationFromName) {
    			startStation = platformOfRoute;
    		} else if (platformOfRoute.Platform__r.Station__r.Name == stationToName) {
    			stopStation = platformOfRoute;
    		}
    	}
    	Decimal numberOfFirstStation = startStation.Station_Number__c;
    	Decimal numberOfLastStation = stopStation.Station_Number__c;
    	return numberOfLastStation - numberOfFirstStation;
    }
    
    private Double calculatePrice(String carriageClass, Decimal stations, String discount ) {
		double singleTicketPrice = 0.0d;
		Decimal classPrice = 0.0d;
		Decimal myDiscount = 1.0d;
		Decimal pricePerStation = 1.8d; 
		
		if (carriageClass == '1') {
			classPrice = 50.0d;
		} else if(carriageClass == '2') {
			classPrice = 25.0d;
		} else {
			classPrice = 50.0d;
		}
		
		if (discount == 'Normal') {
			myDiscount = 1.0d;
		} else if(discount == 'Student') {
			myDiscount = 2.0d;
		}
		
		singleTicketPrice = ( classPrice + ( stations * pricePerStation) ) / myDiscount;
		system.debug(singleTicketPrice);
		system.debug(stations);
		ticketsPrice += singleTicketPrice;
		
		return singleTicketPrice;
    }
    
    public Double getTicketsPrice() {
    	return ticketsPrice;
    }
          
    public List<String> getTicketsList() {
		return ticketsList;
	}
	
	public String getSeatPositionName(Integer positionOfElement) {
      	return ( windowTicket.get(positionOfElement) == true ) ? 'NEAR WINDOW' : 'CORRIDOR';
	}
	
	public List<String> getInvoiceTicket() {
		return invoiceTicket;
	}
	
	public PageReference addElementToTicket() {
      	firstNameTicket.add(firstName);
      	lastNameTicket.add(lastName);
      	emailTicket.add(email);
      	pinTicket.add(pin);
      	discountTicket.add(ticket.Discount__c);
		classTicket.add(trainCarriage.Class__c);
		windowTicket.add(isWindow);
		nearTableTicket.add(isTable);
  	
      	Integer j = ticketsList.size();
		ticketsList.add( 'First Name ' + firstNameTicket.get(j) + ' ' + 'Last Name ' + lastNameTicket.get(j) + ' '
		+ 'Email ' + emailTicket.get(j) + ' ' + 'PIN ' + pinTicket.get(j) + ' '
		+ 'Discount ' + discountTicket.get(j) + ' ' + 'Class ' + classTicket.get(j) + ' ' 
		+ 'Seat Spot ' + getSeatPositionName(j) + ' ' + 'Near Table ' + nearTableTicket.get(j) );
		
      	return null;
	}
      
    public pageReference invoiceShow() {
    	for(Integer i = 0; i < ticketsList.size(); i++) {
			setTicketAndInvoiceData(i);
    	}
		return Page.TicketPdfInvoice;
    }
	
    public PageReference moveToSearchStationPage() {
    	return null;
    }
	
	public PageReference deleteTicket() {
		Integer indexOfTicket = getIndexOfTicket();
		ticketsList.remove( indexOfTicket );
		
		firstNameTicket.remove(indexOfTicket);
		lastNameTicket.remove(indexOfTicket);
		pinTicket.remove(indexOfTicket);
		emailTicket.remove(indexOfTicket);
		discountTicket.remove(indexOfTicket);
		classTicket.remove(indexOfTicket);
		windowTicket.remove(indexOfTicket);
		nearTableTicket.remove(indexOfTicket);
		return null;
	}
	
	public Integer getIndexOfTicket() {
		Integer indexOfTicket = 0;
		for (String s : ticketsList) {
			if ( s != ticketToDelete ) {
				indexOfTicket ++;
			} else {
				return indexOfTicket;
			}
		}
		return null;
	}
	
	public class TicketData {
		public String stationFromName {get; set;}
		public String carrierClass {get; set;}
		public String stationToName {get; set;}
		public String discount {get; set;}
		public Double price {get; set;}
		public String carriageClass {get; set;}
		public String departueDate {get; set;}
		public String seatplace {get; set;}
		public String withTable {get; set;}
		public Integer pin { get; set; }
	}
}