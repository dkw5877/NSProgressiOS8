# NSProgressiOS8
Example of NSProgress Reporting using iOS 8

This is a simple example app to demonstrate the NSProgress object progress reporting mechanisom using progress tree. This app creates a single parent NSOperation that spawns 3 download task operations which download a file from a URL. Each download task then spawns an Upload task opetation (simulated using download tasks) to illustrate the concept post-processing on an operation. 
