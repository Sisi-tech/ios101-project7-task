import UIKit

class TaskListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!

    var tasks = [Task]()
    
    var onComposeTask: ((Task) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure table view
        tableView.dataSource = self
        tableView.delegate = self
        
        // Hide top cell separator
        tableView.tableHeaderView = UIView()
        
        // Load tasks
        refreshTasks()
    }

    // MARK: - Navigation

    @IBAction func didTapNewTaskButton(_ sender: Any) {
        performSegue(withIdentifier: "ComposeSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ComposeSegue" {
            if let composeNavController = segue.destination as? UINavigationController,
               let composeViewController = composeNavController.topViewController as? TaskComposeViewController {

                composeViewController.taskToEdit = sender as? Task

                composeViewController.onComposeTask = { [weak self] task in
                    task.save()
                    self?.refreshTasks()
                }
            }
        }
    }

    private func refreshTasks() {
        tasks = Task.getTasks()
        emptyStateLabel.isHidden = !tasks.isEmpty
        tableView.reloadData()
    }
}

extension TaskListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        let task = tasks[indexPath.row]
        cell.configure(with: task, onCompleteButtonTapped: { [weak self] task in
            task.save()
            self?.refreshTasks()
        })
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            Task.save(tasks)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension TaskListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let selectedTask = tasks[indexPath.row]
        performSegue(withIdentifier: "ComposeSegue", sender: selectedTask)
    }
}

