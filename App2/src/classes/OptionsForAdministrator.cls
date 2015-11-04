public with sharing class OptionsForAdministrator {
	public PageReference showListOfTrains() {
		PageReference outPage = Page.ListOfTrains;
		return outPage;
	}
	
	public PageReference showAddNewTrains() {
		PageReference outPage = Page.NewTrain;
		return outPage;
	}
	public PageReference showListOfCities() {
		PageReference outPage = Page.Cities;
		return outPage;
	}
	
	public PageReference showAddNewCityView() {
		PageReference outPage = Page.Add_City;
		return outPage;
	}
	public PageReference showListOfCarriage() {
		PageReference outPage = Page.Carriages;
		return outPage;
	}
	
	public PageReference showAddNewCarriageView() {
		PageReference outPage = Page.newCarriage;
		return outPage;
	}
	
	public PageReference showListOfStations() {
		PageReference outPage = Page.Stations;
		return outPage;
	}
	
	public PageReference showAddNewStationView() {
		PageReference outPage = Page.Add_Station;
		return outPage;
	}
	
	public PageReference showListOfRoutes() {
		PageReference outPage = Page.Routes;
		return outPage;	
	}
	
	public PageReference showAddNewRouteView() {
		PageReference outPage = Page.newRoute;
		return outPage;
	}
	
}