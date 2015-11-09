public class TicketCtrl {
    public String firstName { get; public set; }
	public String lastName { get; public set; }
	public String pin { get; public set; }
	public String email { get; public set; }
	public Boolean isInvoiceNeed { get; public set; }
	public String businessName { public get; public set; }
	public String nip { get; public set; }
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
	public Id trainFoundId { get; set; }
	public String stationFromName { get; set; }
	public String stationToName { get;set; }
	public List<String> firstNameTicket = new List<String>();
	public List<String> lastNameTicket = new List<String>();
	public List<String> pinTicket = new List<String>();
	public List<String> emailTicket = new List<String>();
	public List<String> discountTicket = new List<String>();
	public List<String> classTicket = new List<String>();
	public List<Boolean> windowTicket = new List<Boolean>();
	public List<Boolean> nearTableTicket = new List<Boolean>();
	public List<String> invoiceTicket = new List<String>();
    public Double ticketsPrice = 0.0d;
    public Boolean rerender { get; set; }
	public Boolean showInvoiceBoolean {get;set;}
	
    Station__c cityFromStation, cityToStation;
   	Seat__c freeSeat;
	Boolean foundSeat = false;
	Platform_Of_Route__c platformOfroute;
	List<Platform_Of_Route__c> allRouteStation;
    Train_on_Route__c t;
	List<Carriage_on_Train__c> c;
	List<Seat__c> seatList;
	List<Seat_Reservation_on_Route__c> seatReservationOnRoute;	
	Boolean problemEncountered = false;
	
	public TicketCtrl() {
		showInvoiceBoolean = false;
		saveDataFromFindRoutePage();
		hideOrShowNearTableSection();
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
    	updateNumberOfFreeSeatSpots();
	}
	
	public List<SelectOption> getClassOptions() {
        List<SelectOption> ClassOptions = new List<SelectOption>();
        //Integer i = 1;
        for(Carriage_On_Train__c classOption : [SELECT Carriage__r.Class__c FROM Carriage_on_Train__c 
			 								 WHERE Train__c IN (SELECT Train__c FROM Train_On_Route__c WHERE Id = :trainFoundId)]) {
	        if (classOption.Carriage__r.Class__c == 'Buffet Car') {
	        	classOptions.add(new SelectOption(classOption.Carriage__r.Class__c, 'Buffet Car'));
	        }
	        else if (classOption.Carriage__r.Class__c == 'First') {
	        	classOptions.add(new SelectOption(classOption.Carriage__r.Class__c, 'First'));
	        }
	        else {
	        	classOptions.add(new SelectOption(classOption.Carriage__r.Class__c, 'Second'));
	        }
        }
        return classOptions;
    }
	
	public void saveDataFromFindRoutePage() {
		routeToBuyTicketForId = ApexPages.currentPage().getParameters().get('routeToBuyTicketForId');
		stationFromName = ApexPages.currentPage().getParameters().get('stationFromName');
		stationToName = ApexPages.currentPage().getParameters().get('stationToName');
		trainFoundId = ApexPages.currentPage().getParameters().get('trainFoundId');
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
		for ( ticketInListIndex = 0; ticketInListIndex < ticketsList.size(); ticketInListIndex++) {
			for (Carriage__c currentCarriage : getAdequateCarriages(ticketInListIndex)) {
				for (Seat__c singleSeat : seatList) {
					if (singleSeat.Carriage__r.Id == currentCarriage.Id && !singleSeat.IsTaken__c) {
							trainCarriage = currentCarriage;
							//singleSeat.IsTaken__c = true;
							freeSeat = singleSeat;
							insertTickets(ticketInListIndex);
							break;
					}
				}
			}
		}
		
		if	(!problemEncountered) {
			return Page.TicketPdfPage;
		}
		
    	return null;
	}
	
	public Integer allFreeSpots {get; set;}
	public Integer nearWindowFreeSpots {get; set;}
	public Integer nearTableFreeSpots {get; set;}
	public Integer nearTableAndWindowFreeSpots {get; set;}
	public Integer nearCorridorFreeSpots { get; set; }
	public Integer nearCorridorAndTableFreeSpots { get; set; }
	
	public void updateNumberOfFreeSeatSpots() {
		allFreeSpots = 0;
		nearWindowFreeSpots = 0;
		nearTableFreeSpots = 0;
		nearTableAndWindowFreeSpots = 0;
		nearCorridorFreeSpots = 0;
		nearCorridorAndTableFreeSpots = 0;
		
		List<Integer> myfreeSpots = new List<Integer>();
		
		for (Carriage_on_Train__c carriage : c) {
			List<Seat__c> freeSeatsList = [SELECT IsTaken__c,Near_Window__c, Table__c, Carriage__r.Id, Name FROM Seat__c WHERE IsTaken__c = false AND Carriage__r.Id = :carriage.Carriage__r.Id];
			for (Seat__c seat : freeSeatsList) {
				
				if(seat.Near_Window__c) {
					nearWindowFreeSpots++;
				}
				
				if(seat.Table__c) {
					nearTableFreeSpots++;
				}
				
				if(seat.Near_Window__c && seat.Table__c ) {
					nearTableAndWindowFreeSpots++;
				}
				
				if(!seat.Near_Window__c) {
					nearCorridorFreeSpots++;
				}
				
				if(!seat.Near_Window__c &&  seat.Table__c) {
					nearCorridorAndTableFreeSpots++;
				}
				
				allFreeSpots++;
			}
		}
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
    	pass.PIN__c = Decimal.valueOf(pinTicket.get(ticketInListIndex));
    	
    	if (isInvoiceNeed) {
    		pass.Company_Name__c = businessName;
    		pass.NIP__c = Decimal.valueOf(nip);
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
    		problemEncountered = true;
    	}
    	
    	if(problemEncountered) {
    		showInsertErrorMsg();
    	} else {
		 	setTicketAndInvoiceData(ticketInListIndex);
    	}
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
		if (!isErrorInForms() && isTicketAvailable()) {
			showInvoiceBoolean = true;
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
		}
      	return null;
	}
	
	public Boolean isTicketAvailable() {		
		
		if (allFreeSpots > 0) {
			if(isWindow && isTable  && nearTableAndWindowFreeSpots > 0) {
				nearTableAndWindowFreeSpots--;
				nearTableFreeSpots--;
				nearWindowFreeSpots--;
				allFreeSpots--;
				return true;
			} else if(isWindow == false && isTable == true  && nearCorridorAndTableFreeSpots > 0) {
				nearCorridorAndTableFreeSpots--;
				nearTableFreeSpots--;
				nearCorridorFreeSpots--;
				allFreeSpots--;
				return true;
			} else if(isWindow && nearWindowFreeSpots > 0) {
				nearWindowFreeSpots--;
				nearTableAndWindowFreeSpots--;
				allFreeSpots--;
				return true;
			} else if(isWindow == false && nearCorridorFreeSpots > 0) {
				nearCorridorFreeSpots--;
				nearCorridorAndTableFreeSpots--;
				allFreeSpots--;
				return true;
			} else if(isTable && nearTableFreeSpots > 0) {
				nearTableFreeSpots--;
				nearTableAndWindowFreeSpots--;
				allFreeSpots--;
				return true;
			} else {
				showTicketNotAvailableMsg();
				return false;
			} 
		} else {
				showTicketNotAvailableMsg();
				return false;
			}
	}
      
    public pageReference invoiceShow() {
    	for(Integer i = 0; i < ticketsList.size(); i++) {
			setTicketAndInvoiceData(i);
    	}
		return Page.TicketPdfInvoice;
    }
	
    public PageReference moveToFindRoutePage() {
    	return Page.FindRoute;
    }
	
	public PageReference deleteTicket() {
		showInvoiceBoolean = false;
		Integer indexOfTicket = getIndexOfTicket();
		addSeatPlaceAsAvailable(indexOfTicket);
		
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
	
	public void addSeatPlaceAsAvailable(Integer indexOfTicket) {
		
		if(windowTicket.get(indexOfTicket) == true && nearTableTicket.get(indexOfTicket) == true) {
			nearTableAndWindowFreeSpots++;
			nearTableFreeSpots++;
			nearWindowFreeSpots++;
			allFreeSpots++;
		} else if(windowTicket.get(indexOfTicket) == false && nearTableTicket.get(indexOfTicket) == true) {
			nearCorridorAndTableFreeSpots++;
			nearTableFreeSpots++;
			nearCorridorFreeSpots++;
			allFreeSpots++;
		} else if(windowTicket.get(indexOfTicket) == true) {
			nearWindowFreeSpots++;
			nearTableAndWindowFreeSpots++;
			allFreeSpots++;
		} else if(windowTicket.get(indexOfTicket) == false) {
			nearCorridorFreeSpots++;
			nearCorridorAndTableFreeSpots++;
			allFreeSpots++;
		} else if(nearTableTicket.get(indexOfTicket) == true) {
			nearTableFreeSpots++;
			nearTableAndWindowFreeSpots++;
			allFreeSpots++;
		}
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
		public String pin { get; set; }
	}
	
	public void hideOrShowNearTableSection() {
		if ([SELECT Carriage__r.Carriage_With_Tables__c FROM Carriage_on_Train__c 
			 WHERE (Train__c IN 
			(SELECT Train__c FROM Train_On_Route__c WHERE Id = :trainFoundId)
			 AND Carriage__r.Carriage_With_Tables__c = true)].size()>0) {
			rerender = true;
		}
		else {
			rerender = false;
		}
	}
	
	public Boolean isErrorInForms() {
		Boolean errorInForm = false;
		
		if (!firstName.isAlpha() || String.isBlank(firstName)) {
			showWrongFieldValueMsg('FIRST NAME');
			errorInForm = true;
		}
		
		if (!lastName.isAlpha() || String.isBlank(lastName)) {
			showWrongFieldValueMsg('LAST NAME');
			errorInForm = true;
		}
		
		if ( pin.length() != 11 || String.isBlank(pin) || !pin.isNumeric() ) {
			showWrongFieldValueMsg('PIN');
			errorInForm = true;
		}

		if (!hasValidEmail(email)) {
			showWrongFieldValueMsg('EMAIL');
			errorInForm = true;
		}
			
		if (isInvoiceNeed) {
			if(String.isBlank(businessName) || !businessName.isAlphaNumericSpace()) {
				showWrongFieldValueMsg('BUSINESS NAME');
				errorInForm = true;
			}
			
			if(nip.length() != 11 || String.isBlank(nip) || !nip.isNumeric()) {
				showWrongFieldValueMsg('NIP');
				errorInForm = true;
			}
			
			if (String.isBlank(postalCode) || !postalCode.remove('-').isNumeric() || postalCode.startsWith('-') || postalCode.endsWith('-')) {
				showWrongFieldValueMsg('POSTAL CODE');
				errorInForm = true;
			}
			
			if (String.isBlank(city) || !city.isAlphaNumericSpace()) {
				showWrongFieldValueMsg('CITY');
				errorInForm = true;
			}
			
			if (String.isBlank(street) || street.containsAny('!@#$%^&*()_+|}{:""<>?;[]`~=_\'\"')) {
				showWrongFieldValueMsg('STREET');
				errorInForm = true;
			}			
		}
		return errorInForm;
	}
	
	public Boolean hasValidEmail(String email) {
		return (email != null && email.length() > 5 && !email.containsAny('!#$%^&*()+=`~~<,>?/:;""{[}|]\\\"\'') && !email.startsWith('@') && !email.endsWith('@') && email.contains('@') && email.contains('.') && !email.startsWith('.') && !email.endsWith('.'));
	}
	
	public void showWrongFieldValueMsg(String fieldName) {
		ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Wrong ' + fieldName + ' value');
		ApexPages.addMessage(errorMsg);
	}
	
	public void showInsertErrorMsg() {
		ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Order error while saving data. Please check form.');
		ApexPages.addMessage(errorMsg);
	}
	
	public void showTicketNotAvailableMsg() {
		ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'No Ticket Available for selected options.');
		ApexPages.addMessage(errorMsg);
	}
}