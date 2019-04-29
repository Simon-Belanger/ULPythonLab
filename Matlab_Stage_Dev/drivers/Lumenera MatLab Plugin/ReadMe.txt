Lumenera's Matlub Plug-in requirements:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 - the Microsoft Visual Studio 2008 redistributable files are required and can be downloaded directly from 
   Microsoft Website.
 - The lucamapi.dll(C:\windows\system32) have to be at version 2.1.0.241 or later. If you have a previous 
   version install than just rename the lucamapi.dll.tmp in this archive to lucamapi.dll.  Remember when updating 
   to new Lucam software to delete the dll.  keep the dll file to the current directory to not affect any other 
   software installation for the camera.


Lumenera's MatLab Plug-in Installation Instructions:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To install the Lumenera MatLab Camera plug-in:

1. Extract all the files contained within this .zip file into a directory of your choice, such as C:\Lumenera MatLab Plugin.
2. Run the install.bat file included in the C:\Lumenera Matlab Plugin directory by either double-clicking it in a Windows
   Explorer window or by opening a Command Prompt window and typing the following

	C:
	cd "\Lumenera Matlab Plugin"
	install <option>

	Where <option> can be either:
	1 -> For Matlab and Imaq 2009 and earlier versions for Windows 32 bit 
	2 -> For Matlab and Imaq 2010 and later versions for Windows 32 bits
	3 -> For Matlab and Imaq 2010 and later versions for Windows 64 bits

3. In MatLab, add this newly created folder to Matlab's search path (under the File->Set Path->Add Folder... menu option).



Included with this plug-in, we have added some sample scripts that demonstrate how to access your Lumenera camera within Matlab. To install sample scripts, 
add the C:\Lumenera MatLab Plugin\Sample folder to Matlab's path (File->Set Path->Add Folder.../Samples menu option).


Lumenera's Image Acquisition Toolkit Adaptor Installation Instructions:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To install the Image Acquisition Toolkit Adaptor, use the following commands:

	>> imaqregister('<path to containing folder>\lumeneraimaq.dll');
	>> imaqreset

Where <path to containing folder> is the path to the folder where lumeneraimaq.dll is located, typically C:\Lumenera Matlab Plugin.


To uninstall the Adapter, type the following:
>> imaqregister('<path to containing folder>\lumeneraimaq.dll', 'unregister');
>> imaqreset



Lumenera's MatLab Plug-In Usage Notes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Lumenera MatLab Plug-in contains all the necessary functions needed to access your Lumenera camera. Most of the function contain an extra parameter that defines the camera number you wish to work with. This plug-in currently supports accessing up to 25 cameras at once.

The new LucamTakeSynchronousSnapshots() function will take snapshots from all the cameras that have an open connection. Also note that the frame size required for this function has to be the same for each camera being used. 