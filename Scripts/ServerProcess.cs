using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;


public class ServerProcess
{
	private Process _process;

	private string _arguments;
    public string Arguments {
		get {
			return _arguments;
		} set {
			_arguments = value;
		}
	}

	private string _workingDir;
	public string WorkingDir { 
		get {
			return _workingDir;
		}
		set{
			if (Path.) {

			}
		}
	}

	private string _javaPath;
	public string JavaPath { get; set; }

	public event EventHandler ServerStartedEvent;
    public event EventHandler ServerReadyEvent;
    public event EventHandler ServerStoppingEvent;
    public event EventHandler serverStoppedEvent;
    public event EventHandler ServerKilledEvent;

    public delegate void ServerOutputHandler(object sender, ServerOutputArgs args);
    public event ServerOutputHandler ServerOutputEvent;

    public delegate void ServerErrorOutputHandler(object sender, ServerErrorOutputArgs args);
    public event ServerErrorOutputHandler ServerErrorOutputEvent;

	public ServerProcess() {

	}

    public void StartServer() {
		if (ServerIsRunning()) {
            throw new InvalidOperationException("Server cannot be started if it is already running.");
		}

		process = new Process();
		process.StartInfo.FileName = JavaPath;
		process.StartInfo.Arguments = Arguments;
		process.StartInfo.WorkingDirectory = WorkingDir;
		process.StartInfo.UseShellExecute = false;
		process.StartInfo.RedirectStandardOutput = true;
		process.StartInfo.RedirectStandardError = true;
		process.StartInfo.RedirectStandardInput = true;
		process.StartInfo.UseShellExecute = false;
		process.StartInfo.CreateNoWindow = true;
		process.EnableRaisingEvents = true;

		try
		{
			process.OutputDataReceived += (sender, args) => SendServerOutput(args.Data);
			process.ErrorDataReceived += (sender, args) => SendServerErrorOutput(args.Data);
			process.Exited += (sender, args) => OnServerExit();
		} catch (Exception e) {
            throw new SystemException("Failed to subscribe to process events.");
		}

		try
		{
			process.Start();
		} catch (ObjectDisposedException e) {
			throw e;
		} catch (InvalidOperationException) {
			throw new InvalidOperationException("Failed to start the process. JavaPath was not specified.");
		} catch (Win32Exception e) {
			throw e;
		} catch (PlatformNotSupportedException) {
			throw new PlatformNotSupportedException("The current operating system does not have shell support.");
		}

		if (process == null || process.HasExited) {
			// TODO: LOG
			return;
		}

		process.BeginOutputReadLine();
		process.BeginErrorReadLine();

		// GD.Print("owo");
		EmitSignal(SignalName.ServerStarted);
	}

	public void StopServer() {
		if (!ServerIsRunning()) {
			GD.PrintErr("Server was already stopped");
			return;
		}

		try {
			process.StandardInput.Write("stop\n");
		} catch {
			GD.PrintErr("Couldn't stop server, but it was running.");
			return;
		}
	}

	public void KillServer() {
		if (!ServerIsRunning()) {
			GD.PrintErr("Server was already stopped");
			return;
		}

		process.Kill();
	}

	public bool ServerIsRunning() {
		// GD.Print("Process" + process.ToString());
		// GD.Print("Has Exited" + process.HasExited);
		try {
			return process != null && !process.HasExited;
		} catch {
			return false;
		}
	}

	public void DeleteWorld() {
		if (!ServerIsRunning()) {
			Directory.Delete(workingDir + "\\world\\", true);
			SendServerOutput("World deleted");
		} else {
			GD.PrintErr("Server Running, can't delete world!");
		}
	}

	public void ZipRun() {
		SendServerOutput("Zipping latest run...");
		DateTime time = DateTime.Now;
		GD.Print("It is now: " + time);
		string timeStr = time.ToString("yyyy_dd_M-HH_mm_ss");
		string filePath = savePath + "\\Run-" + timeStr;

		GD.Print("Creating Zip of " + workingDir + "world" + " in " + filePath);

		ZipFile.CreateFromDirectory(workingDir + "world", filePath + ".zip");
		GD.Print("Copying log to " + filePath);
		File.Copy(workingDir + "logs\\latest.log", filePath + ".log");

		SendServerOutput("Run zipped.");
	}

	private void OnServerExit() {
		EmitSignal(SignalName.ServerStopped);
	}

	private void SendServerOutput(string data) {
		// Emit output as event to Godot
		//TODO: remove debug
		// GD.Print("Server Data: ", data);
		if (data != null) {
			if (data.Contains("] [Server thread/INFO]: Done (")) {
				string time = data.Split("(")[1].Split(")")[0];
				GD.Print("Server ready in ", time);
				EmitSignal(SignalName.ServerReady, time);
			}

			if (data.Contains("] [Server thread/INFO]: Stopping the server")) {
				EmitSignal(SignalName.ServerStopping);
			}

			EmitSignal(SignalName.ServerOutput, data);
		}
	}

	private void SendServerErrorOutput(string data) {
		// Emit data as event to Godot
		// GD.Print("Server Error: ", data);
		EmitSignal(SignalName.ServerError, data);
	}

	private void SendServerInput(string input){
		if (ServerIsRunning()) {
			try {
				process.StandardInput.Write(input + "\n");
			} catch {
				GD.PrintErr("Couldn't send input, but the server is running.");
				return;
			}
		}
	}

	protected virtual void OnRaiseServerStartedEvent()
	{
		// Make a temporary copy of the event to avoid possibility of
		// a race condition if the last subscriber unsubscribes
		// immediately after the null check and before the event is raised.
		ServerStartedEvent raiseEvent = ServerStartedEvent;

		// Event will be null if there are no subscribers
		if (raiseEvent != null)
		{
			// Call to raise the event.
			raiseEvent(this);
		}
	}

}

public class ServerOutputArgs : EventArgs
{
    public string Output { get; set; }

	public ServerOutputArgs(string output) {
        Output = output;
    }
}

public class ServerErrorOutputArgs : EventArgs
{
    public string Error { get; set; }

	public ServerErrorOutputArgs(string error) {
        Error = error;
    }
}