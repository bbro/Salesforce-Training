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
	String defaultSitOption = 'okno';
		
	public TicketCtrl() {
		ticket = new Ticket__c();
		carriage = new Carriage__c();
		
	}
	
	public String getDefaultSitOption() {
        return defaultSitOption;
    }
                    
    public void setDefaultSitOption(String defaultSitOption) { this.defaultSitOption = defaultSitOption; }
	
	public List<SelectOption> getSpots() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new Selectoption('okno', 'WINDOW SIDE'));
		options.add(new Selectoption( 'korytarz', 'PASSAGE SIDE'));
		options.add(new Selectoption('stojace', 'STANDING'));
	return options;
	}
	
    public void addTicket() {
    	ticket = new Ticket__c();
    	ticket.name= 'ticket';
    	ticket.Discount__c = getDefaultSitOption();
		
    	Passenger__c passenger = new Passenger__c();
    	passenger.City__c = 'HardCoded';
    	passenger.Company_Name__c = businessName;
    	passenger.Email__c = email;
    	passenger.Name = firstName;
    	passenger.Last_Name__c = lastName;
    	passenger.NIP__c =  nip;
    	passenger.PIN__c = pin;
    	passenger.Postal_Code__c = postalCode;
    	passenger.Street__c = street;
    	
    	Seat__c seat = new Seat__C();
    	//seat.Location__c = getDefaultSitOptions();
    	
    	try {
    		insert passenger;
    		insert ticket;
    	} catch(DmlException e) {
    		system.debug(e.getMessage());
    	}
    }
    
    public PageReference moveToSearchStationPage() {
    	return null;
    }
    
    public PageReference buyTicket() {
    	return null;
    }
}