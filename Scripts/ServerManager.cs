using Godot;
using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;


public partial class ServerManager : Node
{
	// private Control gui;

	private Process process;
	[Export]
	private string arguments;
	[Export]
	private string serverName;
	[Export]
	private string savePath;
	[Export]
	private string workingDir;
	[Export]
	private string javaPath;

	[Signal]
	public delegate void ServerStartedEventHandler();

	[Signal]
	public delegate void ServerReadyEventHandler(string timeToDone);

	[Signal]
	public delegate void ServerStoppingEventHandler();

	[Signal]
	public delegate void ServerStoppedEventHandler();

	[Signal]
	public delegate void ServerKilledEventHandler();

	[Signal]
	public delegate void ServerOutputEventHandler(string serverOutput);

	[Signal]
	public delegate void ServerErrorEventHandler(string serverError);

	[Signal]
	public delegate void ServerNameChangedEventHandler(string oldName, string newName);

	public override void _Ready()
	{
		// Called every time the node is added to the scene.
		// Initialization here.
		// gui = GetNode<Control>("/root/Main");
	}

	public void SetArgs(string newArgs) {
		// GD.Print(String.Format("New arguments {0}", newArgs));
		arguments = newArgs;
	}

	public string GetArgs() {
		return arguments;
	}

	public void SetWorkingDir(string dir){
		workingDir = dir;
	}

	public void SetJavaPath(string path) {
		javaPath = path;
	}

	public void SetSavePath(string newSavePath){
		savePath = newSavePath;
	}

	public string GetSavePath(){
		return savePath;
	}

	public void SetServerName(string newServerName) {
		// GD.Print(String.Format("New server name {0}", newServerName));
		EmitSignal(SignalName.ServerNameChanged, serverName, newServerName);
		serverName = newServerName;
	}

	public string GetServerName() {
		return serverName;
	}

	public void StartServer() {
		if (ServerIsRunning()) {
			GD.Print(":(" + ServerIsRunning());
			return;
		}

		try
		{
			GD.Print("Launching server with " + arguments);
			process = new Process();
			// process = Process.Start("C:\\Program Files\\Eclipse Adoptium\\jdk-17.0.8.7-hotspot\\bin\\java.exe"/**arguments*/);
			// GD.Print("uwu");
			process.StartInfo.FileName = javaPath;
			process.StartInfo.Arguments = arguments;
			process.StartInfo.WorkingDirectory = workingDir;
			process.StartInfo.UseShellExecute = false;
			// GD.Print("You dumb");
			process.StartInfo.RedirectStandardOutput = true;
			process.StartInfo.RedirectStandardError = true;
			process.StartInfo.RedirectStandardInput = true;
			process.StartInfo.UseShellExecute = false;
			process.StartInfo.CreateNoWindow = true;
			process.EnableRaisingEvents = true;
			// GD.Print("that went alright");
			process.OutputDataReceived += (sender, args) => CallDeferred("SendServerOutput", args.Data);
			process.ErrorDataReceived += (sender, args) => CallDeferred("SendServerErrorOutput", args.Data);
			process.Exited += (sender, args) => CallDeferred("OnServerExit");
			// GD.Print("all good here");
			process.Start();
			// GD.Print("got past tthe hard part " + process.StartInfo.RedirectStandardOutput);
			process.BeginOutputReadLine();
			process.BeginErrorReadLine();
			// GD.Print("good heavens");
		} catch (Exception e) {
			GD.PrintErr("Something went wrong starting the server." + e);
			return;
		}

		if (process == null || process.HasExited) {
			// GD.Print("AAAAAAAAAAA");
			return;
		}
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
}
