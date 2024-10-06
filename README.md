# face-id

This project is using [keras-vggface](https://github.com/rcmalli/keras-vggface) to identify similar faces on iOS.
<br/>
Below are few screenshots demonstrating how it works.
<br/>
Keras vggface model was converted to CoreML, and is used directly on iOS device.
<p float="center">
  <img src="https://raw.githubusercontent.com/pavel-zh/face-id/master/sample-screens/screen1.png" width="250" hspace="50"/>
  <img src="https://raw.githubusercontent.com/pavel-zh/face-id/master/sample-screens/screen2.png" width="250"  hspace="50"/> 
</p>
<p float="center">
  <img src="https://raw.githubusercontent.com/pavel-zh/face-id/master/sample-screens/screen3.png" width="250"  hspace="50"/>
  <img src="https://raw.githubusercontent.com/pavel-zh/face-id/master/sample-screens/screen4.png" width="250"  hspace="50"/> 
</p>


Converting Keras model to coreml:

```python
model = VGGFace(
  model='resnet50', include_top=False,
  input_shape=(224, 224, 3),
  pooling='avg'
)
coreml_model = coremltools.converters.keras.convert(
  model,
  input_names="image",
  image_input_names="image"
)
coreml_model.save("vggface-resnet50.mlmodel")
```
