# Virtual Closet AI
# iOS App

Virtual Closet AI is an iOS app that uses machine learning and computer vision to recognize and classify your clothes and recommends outfits based on the weather of the city you're living in!

The app won third prize at the Hack UCSC 2017!

Demo:
[![Watch the video](https://raw.github.com/GabLeRoux/WebMole/master/ressources/WebMole_Youtube_Video.png)](https://www.youtube.com/watch?v=RCF3T90h00s)

The app was built using Xcode 8 and Swift 3. The app provides user login and sign up options. Each user's data in stored on our server using Parse Server backend. We used the Clarifai API to employ computer vision and machine learning. We trained our app to learn concepts (the clothing items) and create a model based on those concepts. We then used the model to recognize and classify clothing items in images taken from either the photo library or the camera. We also used the Open Weather Map API to get the weather of the cities entered by the user. Finally, we devised an algorith that takes into consideration factors like gender, weather, and colors to recommend the best outfits!


We are currently working on adding functionalities such as automatic removal of the background from the images using the OpenCV library and adding view for the whole virtual closet.
