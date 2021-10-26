
import * as THREE from './three.module.js';
import { OrbitControls } from './OrbitControls.js';
import { FontLoader } from './FontLoader.js';
import { TextGeometry } from './TextGeometry.js';


let camera, scene, renderer;

const pointer = new THREE.Vector2();

const raycaster = new THREE.Raycaster();
raycaster.params.Points.threshold = 0.1;

let r_data, m_data;

const r_ids = [];
const r_positions = [];
const r_colours = [];

const m_ids = [];
const m_positions = [];
const m_colours = [];

var sim = [];
var lines = [[],[]];
var points = [];		

let selected;
let clicked;

const r_mean = [];
const m_mean = [];

var direction=0;
const dir_symbols=["rm","mr"];

let sim_max;
let sim_min;

const opacity_low = 0.2;

const colour = new THREE.Color();
const viridis_scale = d3.scaleSequential().domain([0,1])
					.interpolator(d3.interpolateViridis);


function loadSim(direction=0) {

	const load_sim = d3.json("https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2020/" + dir_symbols[direction] + "_nhood_sim.json").then(nhoods => {
		sim[direction]=nhoods;

		// TODO: Not sure if there's a way to avoid 2 loops
		// Normalise colour range by finding min/max
		var sims = [];
		for(var key in nhoods) {
			var nhood = nhoods[key];
			sims.push(nhood.sim[0]);
		}
		sim_min = d3.min(sims);
		sim_max = d3.max(sims);

		var k=0
		for(var key in nhoods) {
			var nhood = nhoods[key];

			const line_points = [];

			// Create mapping lines
			var line_geometry = new THREE.BufferGeometry();
			const line = new THREE.LineSegments(
	    		line_geometry,
	    		new THREE.LineBasicMaterial({
	    			color:new THREE.Color(d3.interpolateTurbo((nhood.sim[0]-sim_min)/(sim_max-sim_min))) 
	    		})
	 		);

			// For each mapping
			let r_index, m_index;
			for(var i in nhood.index) {

				if(direction==0) {
					r_index = k;	
					m_index = nhood.index[i] -1;
				} else {
					r_index = nhood.index[i] -1;	
					m_index = k;
				}

				line_points.push(new THREE.Vector3(points[0].geometry.attributes.position.getX(r_index),
				points[0].geometry.attributes.position.getY(r_index),points[0].geometry.attributes.position.getZ(r_index)));

				line_points.push(new THREE.Vector3(points[1].geometry.attributes.position.getX(m_index),
				points[1].geometry.attributes.position.getY(m_index),points[1].geometry.attributes.position.getZ(m_index)));
				line_geometry.setFromPoints(line_points);
			}

			line_geometry.verticesNeedUpdate = true;
			line.visible = false;
			lines[direction].push(line);
			scene.add(line);

			k = k + 1;
		}

	});

}


function init() {

	document.getElementById("clear_button").addEventListener("click", deselect, false);
	document.getElementById("dir_dropdown").addEventListener("change", changeDirection);

	const sprite = new THREE.TextureLoader().load( 'https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2020/disc.png' );

	scene = new THREE.Scene();
	camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 );
	
	// Load rabbit nhoods...
	r_data = d3.tsv("https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2020/rabbit_nhoods.tsv").then(data => {
		data.forEach(d => {

			d.umapX = Number(d.umapX);
			d.umapY = Number(d.umapY);
			d.umapZ = Number(d.umapZ);

			d.faX = Number(d.faX)*20;
			d.faY = Number(d.faY)*20;

			d.celltype = d.celltype;
			d.colour = d.colour;

			colour.set(d.colour);
			
			r_positions.push(d.umapX-20,d.umapY,d.umapZ);
			//r_positions.push(d.faX-20,d.faY,0);
			r_colours.push(colour.r,colour.g,colour.b,1);

		})

		// Used to position text
		r_mean.push(d3.mean(data, d => d.umapX)-20);
		r_mean.push(d3.mean(data, d => d.umapY));
		r_mean.push(d3.mean(data, d => d.umapZ));


		// Create threejs points
		const r_geometry = new THREE.BufferGeometry();
		r_geometry.setAttribute( 'position', new THREE.Float32BufferAttribute( r_positions, 3 ) );
		r_geometry.setAttribute( 'color', new THREE.Float32BufferAttribute( r_colours, 4 ) );
		r_geometry.computeBoundingSphere();

		const r_material = new THREE.PointsMaterial( { size:0.7,vertexColors:true,
			map:sprite,transparent: true,alphaTest: 0.8} );

		points[0] = new THREE.Points(r_geometry,r_material);
		scene.add( points[0] );


	});


	// Load mouse nhoods...
	m_data = d3.tsv("https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2020/mouse_nhoods.tsv").then(data => {
		data.forEach(d => {
			d.umapX = Number(d.umapX);
			d.umapY = Number(d.umapY)+5;
			d.umapZ = Number(d.umapZ);

			d.faX = Number(d.faX)*20;
			d.faY = Number(d.faY)*20;

			d.celltype = d.celltype;
			d.colour = d.colour;

			colour.set(d.colour);
			m_positions.push(d.umapX+20,d.umapY,d.umapZ);
			//m_positions.push(d.faX+20,d.faY,0);
			m_colours.push(colour.r,colour.g,colour.b,opacity_low);

		})

		// Used to position text
		m_mean.push(d3.mean(data, d => d.umapX)+20);
		m_mean.push(d3.mean(data, d => d.umapY));
		m_mean.push(d3.mean(data, d => d.umapZ));

		const m_geometry = new THREE.BufferGeometry();
		m_geometry.setAttribute( 'position', new THREE.Float32BufferAttribute( m_positions, 3 ) );
		m_geometry.setAttribute( 'color', new THREE.Float32BufferAttribute( m_colours, 4 ) );


		m_geometry.computeBoundingSphere();
		//const m_material = new THREE.PointsMaterial( { size:0.3,vertexColors:true} );
		const m_material = new THREE.PointsMaterial( { size:0.7,vertexColors:true,map:sprite,transparent: true,alphaTest: 0.175} );
		points[1] = new THREE.Points(m_geometry,m_material);
		scene.add( points[1] );


	});

	

	// Load neighbour mappings...
	Promise.all([r_data,m_data]).then((values) => {
		loadSim(0);
		loadSim(1);
	});


	// Add ambient light
	const light = new THREE.AmbientLight(0xffffff);
	scene.add(light);

	// Add text labels
	Promise.all([r_data,m_data]).then((values) => {
		// TODO: Need smarter way to position text relative to points
		createText("Rabbit", r_mean[0], 20, r_mean[2]);
		createText("Mouse", m_mean[0]-5, 20, m_mean[2]);
	})
	


	renderer = new THREE.WebGLRenderer();
	renderer.setPixelRatio( window.devicePixelRatio );
	renderer.setSize( window.innerWidth, window.innerHeight );
	document.body.appendChild( renderer.domElement );

	camera.position.z = 30;
	scene.userData.camera = camera;

	const controls = new OrbitControls( camera, renderer.domElement );
	camera.position.set(8,12,35);
	controls.target.set(3, 5, 0);
	controls.update();
	scene.userData.controls = controls;


}


// Loads helvetica font 
function createText(text,x,y,z) {
	const loader = new FontLoader();
	loader.load( 'https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2020/' + "helvetiker" + '_' + "regular" + '.typeface.json', function ( response ) {
		var font = response;
		addText(text,x,y,z,font);
		return(font)

	} );

}


// Builds text geometry and adds to scene
function addText(text,x,y,z,font) {

	var text_geo = new TextGeometry( text ,{font:font,
		size:2,
		height: 0.5,
		curveSegments: 4,
		bevelEnabled: false});

	text_geo.computeBoundingBox();
	
	var materials = [
		new THREE.MeshPhongMaterial( { color: 0xfffffff, flatShading: true } ), // front
		new THREE.MeshPhongMaterial( { color: 0x808080  } ) // side
	];

	var text_mesh = new THREE.Mesh( text_geo, materials );

	text_mesh.position.x = x;
	text_mesh.position.y = y;
	text_mesh.position.z = z;

	scene.add(text_mesh);
}



function changeNeighbourOpacity(index,opacity) {
	var nhood =  Object.keys(sim[direction])[index];
	for(var i in sim[direction][nhood].index) {
		var nh_index = sim[direction][nhood].index[i] - 1;
		points[1-direction].geometry.attributes.color.setXYZW(nh_index, 
				points[1-direction].geometry.attributes.color.getX(nh_index), 
				points[1-direction].geometry.attributes.color.getY(nh_index), 
				points[1-direction].geometry.attributes.color.getZ(nh_index),opacity); 
	}
	points[1-direction].geometry.attributes.color.needsUpdate = true;		
}


function changeDatasetOpacity(points,opacity) {
	for(let i=0; i< points.geometry.attributes.color.count; i++) {
		points.geometry.attributes.color.setXYZW(i, 
			points.geometry.attributes.color.getX(i), 
			points.geometry.attributes.color.getY(i), 
			points.geometry.attributes.color.getZ(i),opacity); 
	}
	points.geometry.attributes.color.needsUpdate = true;
}




function onHover(event) {
	event.preventDefault();


	if(!clicked) {

		if(selected) {
			lines[direction][selected].visible = false;
			changeNeighbourOpacity(selected, opacity_low);
		}

		pointer.x = ( event.clientX / window.innerWidth ) * 2 - 1;
		pointer.y = - ((event.clientY - renderer.domElement.offsetTop)/ window.innerHeight ) * 2 + 1;

		// Only raycast if not panning (optimization)
		var hits;
		raycaster.setFromCamera(pointer, scene.userData.camera);

		// Raycast to single point
		hits = raycaster.intersectObject(points[direction], false);
		
		
		// Run if we have intersections
		if (hits.length > 0) {
			var index = hits[0].index;

			// Get lines associated with point
			lines[direction][index].visible = true;
			changeNeighbourOpacity(index,1);
			selected = index;
			
		 renderer.render(scene, scene.userData.camera);

		}
	}
}



function onClick(event) {
	event.preventDefault();

	if(!clicked & selected) {
		lines[direction][selected].visible = false;					
		changeNeighbourOpacity(selected,opacity_low);
	}

	pointer.x = ( event.clientX / window.innerWidth ) * 2 - 1;
	pointer.y = - ((event.clientY - renderer.domElement.offsetTop)/ window.innerHeight ) * 2 + 1;

	// Only raycast if not panning (optimization)
	var hits;
	raycaster.setFromCamera(pointer, scene.userData.camera);

	// Raycast to single point
	hits = raycaster.intersectObject(points[direction], false);
	
	// Run if we have intersections
	if (hits.length > 0) {
		var index = hits[0].index;

		// Remove previously clicked mapping
		if(clicked & clicked!=index) {
			lines[direction][clicked].visible = false;						
			changeNeighbourOpacity(clicked,opacity_low);
		}

		// Show mapping
		lines[direction][index].visible = true;
		changeNeighbourOpacity(index,1);
		clicked = index;

		
	 renderer.render(scene, scene.userData.camera);
	}

}

const animate = function () {
	requestAnimationFrame( animate );
	window.addEventListener('mousemove', onHover, false);
	window.addEventListener('click', onClick, false);
	Promise.all([m_data]).then((values) => {points[1].geometry.attributes.color.needsUpdate = true;});
	renderer.render( scene, camera );
};

function changeDirection() {
	var diselected = document.getElementById("dir_dropdown").value
	if (diselected!= direction){
		direction = diselected;
		
		if(diselected == 1) {

			// change opacity
			points[0].material._alphaTest = 0.175;
			points[0].material.needsUpdate = true;
			changeDatasetOpacity(points[0],opacity_low);

			points[1].material._alphaTest = 0.8;
			points[1].material.needsUpdate = true;
			changeDatasetOpacity(points[1],1);

		} else{

			// change opacity
			points[1].material._alphaTest = 0.175;
			points[1].material.needsUpdate = true;
			changeDatasetOpacity(points[1],opacity_low);

			points[0].material._alphaTest = 0.8;
			points[0].material.needsUpdate = true;
			changeDatasetOpacity(points[0],1);
		}

		selected = undefined;
		clicked = undefined;

	}

}


// Remove mapping currently being displayed
function deselect() {
	if(clicked) {
		lines[direction][clicked].visible = false;
		changeNeighbourOpacity(clicked,0.2);
		clicked = undefined;
	}
}



init();
animate();