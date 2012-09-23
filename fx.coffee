# My Coffee ;)

parentDOM = undefined

scene = undefined
camera = undefined
renderer = undefined
geometry = undefined
clock = new THREE.Clock()

radius = 300
particleCount = 25

v = (x, y, z)-> new THREE.Vector3(x, y, z)
c = (x) -> Math.cos(x)
s = (x) -> Math.sin(x)
PI = Math.PI
PI2 = Math.PI * 2


pivotList = undefined
edgeGroup = undefined
particleList = undefined
worldMatrix = new THREE.Matrix4();


stats = new Stats();
stats.setMode(1);
stats.domElement.style.position = 'absolute';
stats.domElement.style.left = '0px';
stats.domElement.style.top = '0px';
document.body.appendChild( stats.domElement );







updatePivots = ->

  for p in pivotList
    p[0].rotation.x += p[1] * 0.01
    p[0].rotation.y += p[1] * 0.01
    p[0].rotation.z += p[1] * 0.01








updateLinks = ->
  for line in edgeGroup
    do (line) ->
      wp0 = line.properties.from.localToWorld(line.properties.from.position.clone()).normalize().multiplyScalar(radius)
      wp1 = line.properties.to.localToWorld(line.properties.to.position.clone()).normalize().multiplyScalar(radius)
      if (wp0.distanceTo(wp1) < radius/3)
        line.visible = true
        line.geometry.vertices = [wp0, wp1]
      else
        line.visible = false











run = ->
  stats.begin();
  time = clock.getElapsedTime() * 0.1

  requestAnimationFrame( updatePivots )
  updateLinks()

  renderer.render( scene, camera )
  stats.end();

  requestAnimationFrame( run );










addnode = (mat, group, velo, position) ->
  particlePivot = new THREE.Object3D();
  group.add( particlePivot )
  pivotList.push([particlePivot, velo ])


  particle = new THREE.Particle(mat)
  particleList.push(particle)
  particle.position = position
  particlePivot.add( particle );

  return particle









addEdge = (nodeA, nodeB) ->
  wp0 = nodeA.localToWorld(nodeA.position.clone()).normalize().multiplyScalar(radius)
  wp1 = nodeB.localToWorld(nodeB.position.clone()).normalize().multiplyScalar(radius)

  geometry = new THREE.Geometry()
  geometry.vertices.push wp0, wp1
  scene.add(line = new THREE.Line( geometry, new THREE.LineBasicMaterial( { color: 0xD57D22, opacity: 0.8 } ) ));
  line.properties = {
  from : nodeA,
  to : nodeB
  }
  edgeGroup.push(line)








threeInit = ->

  parentDOM = document.getElementById("back")
  sw =  1000
  sh =   500
  camera = new THREE.PerspectiveCamera(75, sw / sh, 1, 10000)
  camera.position.z = 500;

  scene = new THREE.Scene()

  renderer = new THREE.CanvasRenderer();
  renderer.setSize( sw, sh );

  parentDOM.appendChild( renderer.domElement );










init = ->
  threeInit()

  canvas = document.createElement( 'canvas' );
  cs = 25;
  canvas.width = cs;
  canvas.height = cs;
  canvas.loaded = true;
  context = canvas.getContext( '2d' )

  gradient = context.createRadialGradient(  cs/2, cs/2, 0, cs / 2, cs / 2, cs/3 );
  gradient.addColorStop( 0, 'rgba(213, 125, 34, 0.9)' );
  gradient.addColorStop( 1, 'rgba(89, 51, 12, 0.1)' );

  context.fillStyle = gradient
  context.arc cs/2, cs/2, canvas.width/3, 0, PI2, true
  context.fill()

  circle_material = new THREE.ParticleBasicMaterial
    map: new THREE.Texture(canvas)
    transparent: true

  pivotList = []
  particleList = []
  edgeGroup = []
  group = new THREE.Object3D()

  velo1 = 1
  velo2 =  - 1
  for phi in [0..PI2] by PI/5
    for theta in [0.. PI2] by PI/ 5.5
      addnode circle_material, group,  velo1 , v(c(theta) * c(phi) , c(theta) * s(phi), s(theta)).multiplyScalar(radius)

  addnode circle_material, group, Math.random() * 2 - 1, v(Math.random() * 2 - 1, Math.random() * 2 - 1, Math.random() * 2 - 1).normalize().multiplyScalar(radius) for _ in [0..particleCount]

  edgePair = (->
    r = []
    i = j = 0
    len = particleList.length
    while i < len
      n0 = particleList[i]
      j = i+1
      while j < len
        n1 = particleList[j]
        r.push [n0, n1]
        j++
      i++
    r
  )()

  addEdge p[0], p[1] for p in edgePair
  edgePair = null;

  scene.add( group );

  run()









if (window.addEventListener)
  window.addEventListener("load", init, false);
else if (window.attachEvent)
  window.attachEvent("onload", init);
else window.onload = init;



