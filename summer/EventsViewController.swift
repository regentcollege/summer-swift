import UIKit
import AFDateHelper

class EventsViewController: UIViewController, DocumentStoreDelegate {
    @IBOutlet var tableView: UITableView!
    
    var documentStore: DocumentStore!
    
    var events: [EventViewModel] {
        return documentStore.getEvents()
    }
    
    var eventsFiltered = [EventViewModel]()
    var eventsFiltering = false
    var eventCategories = [String: [EventViewModel]]()
    var eventsWithSections = [String : [EventViewModel]]()
    var sectionTitles = [String]()
    
    var isCollapsedView: Bool {
        return splitViewController?.isCollapsed ?? true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentStore.delegate = self
        
        categorizeEvents()
        groupEvents()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 130
        
        if #available(iOS 11.0, *) {
            // table layout is fine
        }
        else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search events"
        searchController.searchBar.scopeButtonTitles = ["All", "May", "June", "July", "EPL"]
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
    }
    
    // provide the initial detail view for iPad
    // must go here and not viewDidLoad because iPhone begins not collapsed
    override func viewWillAppear(_ animated: Bool) {
        let eventIndexToShow = IndexPath(row: 0, section: 0)
        
        // this isn't working
        /*var sectionPosition = 0
        for event in events {
            if let startDate = event.startDate {
                if(Settings.currentDate.compare(.isSameDay(as: startDate)) || Settings.currentDate.compare(.isEarlier(than: startDate))) {
                    eventIndexToShow = IndexPath(row: 0, section: sectionPosition)
                    break
                }
            }
            sectionPosition += 1
        }
        self.tableView.scrollToRow(at: eventIndexToShow, at: .top, animated: false)
        */
        
        if !isCollapsedView {
            self.tableView.selectRow(at: eventIndexToShow, animated: true, scrollPosition:UITableViewScrollPosition.none)
            self.performSegue(withIdentifier: "showEvent", sender: eventIndexToShow)
        }
    }
    
    func documentsDidUpdate() {
        DispatchQueue.main.async {
            self.groupEvents()
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showEvent"?:
            if let section = tableView.indexPathForSelectedRow?.section,
                let row = tableView.indexPathForSelectedRow?.row,
                let navViewController = segue.destination as? UINavigationController,
                let eventDetailViewController = navViewController.topViewController as? EventDetailViewController {
                let event = getEventBy(section: section, row: row)
                eventDetailViewController.event = event
                eventDetailViewController.lecturer = documentStore.getLecturerBy(id: event.lecturerId)
            }
        default:
            preconditionFailure("Unexpected segue identifer")
        }
    }
    
    private func categorizeEvents() {
        eventCategories.removeAll()
        
        for event in events {
            if let startDate = event.startDate {
                let startMonth = startDate.toString(style: .month)
                
                // You must initialize the array at that key if it doesn't exist yet
                var existingItems = eventCategories[startMonth] ?? [EventViewModel]()
                existingItems.append(event)
                eventCategories[startMonth] = existingItems
                
                if let endDate = event.endDate {
                    let endMonth = endDate.toString(style: .month)
                    if(startMonth != endMonth) {
                        var existingItems = eventCategories[endMonth] ?? [EventViewModel]()
                        existingItems.append(event)
                        eventCategories[endMonth] = existingItems
                    }
                }
            }
            
            if(event.isEPL) {
                var existingItems = eventCategories["EPL"] ?? [EventViewModel]()
                existingItems.append(event)
                eventCategories["EPL"] = existingItems
            }
        }
    }
    
    private func groupEvents() {
        sectionTitles.removeAll()
        eventsWithSections.removeAll()
        
        var eventsToGroup = events
        if(eventsFiltering) {
            eventsToGroup = eventsFiltered
        }
        var sectionTitle = ""
        for event in eventsToGroup {
            if let startDate = event.startDate {
                let thisSectionTitle = startDate.toString(format: .isoDate)
                if thisSectionTitle != sectionTitle {
                    sectionTitle = thisSectionTitle
                    eventsWithSections[sectionTitle] = [EventViewModel]()
                    sectionTitles.append(sectionTitle)
                }
                eventsWithSections[thisSectionTitle]?.append(event)
            }
            else {
                var existingItems = eventsWithSections["_"] ?? [EventViewModel]()
                existingItems.append(event)
                eventsWithSections["_"] = existingItems
            }
        }
    }
    
    private func getEventBy(section: Int, row: Int) -> EventViewModel {
        let sectionTitle = sectionTitles[section]
        let events = eventsWithSections[sectionTitle]
        return events![row]
    }
}

// MARK: - UITableViewDataSource
extension EventsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = sectionTitles[section]
        let events = eventsWithSections[sectionTitle]
        return events!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventCell {
            let event = getEventBy(section: indexPath.section, row: indexPath.row)
            cell.configureWith(event: event, lecturer: documentStore.getLecturerBy(id: event.lecturerId))
            
            if !isCollapsedView {
                cell.accessoryType = .none
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
}

// MARK: - UITableViewDelegate
extension EventsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showEvent", sender: EventsViewController())
        if isCollapsedView {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - UISearchResultsUpdating
extension EventsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterEvents(forSearch: searchController.searchBar.text!, scope: scope)
    }
    func filterEvents(forSearch: String, scope: String = "All") {
        if scope == "All" {
            self.eventsFiltering = false
            self.eventsFiltered = self.events
        }
        else {
            self.eventsFiltering = true
            if let eventsInCategory = self.eventCategories[scope] {
                self.eventsFiltered = eventsInCategory
            }
            else {
                self.eventsFiltered = [EventViewModel]()
            }
        }
        
        if !forSearch.isEmpty {
            self.eventsFiltered = self.eventsFiltered.filter({ $0.title.lowercased().contains(forSearch.lowercased()) })
            self.eventsFiltering = true
        }
        
        self.groupEvents()
        self.tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension EventsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchBar.resignFirstResponder()
        filterEvents(forSearch: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.endEditing(true)
        searchBar.selectedScopeButtonIndex = 0
        
        if self.eventsFiltering {
            self.eventsFiltering = false
            self.groupEvents()
            self.tableView.reloadData()
        }
    }
}
