//
//  MapaViewController.m
//  EquiposFutbol
//
//  Created by macbook on 28/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapaViewController.h"
#import "EstadioFutbol.h"

@implementation MapaViewController

@synthesize estadiosFutbolArray,mapa;

-(void)cargarDatosDemo
{
    NSMutableArray *datosEstadiosArray=[[NSMutableArray alloc] initWithCapacity:2];
    [datosEstadiosArray addObject:[EstadioFutbol objetoEstadioFutbol:@"Santiago Bernabeu" ciudad:@"Madrid" latitud:[[NSNumber alloc] initWithDouble:40.453042] longitud:[[NSNumber alloc] initWithDouble:-3.688294]]];
    [datosEstadiosArray addObject:[EstadioFutbol objetoEstadioFutbol:@"Nou Camp" ciudad:@"Barcelona" latitud:[[NSNumber alloc] initWithDouble:41.380887] longitud:[[NSNumber alloc] initWithDouble:2.122826]]];   
    self.estadiosFutbolArray=datosEstadiosArray;
    
    for (EstadioFutbol *estadio in self.estadiosFutbolArray) {
        CLLocationCoordinate2D coord;
        coord.latitude=[estadio.latitud doubleValue];
        coord.longitude=[estadio.longitud doubleValue];
        MiAnotacion * anotacion=[[MiAnotacion alloc] initWithCoordinate:coord title:estadio.nombreEstadio subtitle:estadio.ciudad];
        
        
        [mapa addAnnotation:anotacion];
    }
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 40.453042;
    zoomLocation.longitude= -3.688294;
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 600000, 600000);
    // 3
    MKCoordinateRegion adjustedRegion = [mapa regionThatFits:viewRegion];                
    // 4
    [mapa setRegion:adjustedRegion animated:YES];     
    
}

-(void)aniadirEstadioBBDD:(EstadioFutbol *)estadio
{
    CoreDataManager *coreDataManager=[CoreDataManager sharedInstance];
    NSManagedObject *estadioFutbol=[NSEntityDescription insertNewObjectForEntityForName:@"EstadioFutbol" inManagedObjectContext:[coreDataManager managedObjectContext]];
    [estadioFutbol setValue:estadio.nombreEstadio forKey:@"nombreEstadio"];
    [estadioFutbol setValue:estadio.ciudad forKey:@"ciudad"];
    [estadioFutbol setValue:estadio.latitud forKey:@"latitud"];
    [estadioFutbol setValue:estadio.longitud forKey:@"longitud"];
    [coreDataManager saveContext];    
}


-(void)tratarDatosNube:(NSString *)responseString
{
    
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSLog(@"fechaActualizacion_preference -->%@",[userDefaults objectForKey:@"fechaActualizacion_preference"]);
    NSString *strFechaActualizacion=[userDefaults objectForKey:@"fechaActualizacion_preference"];        
    
    NSDictionary *root=[responseString JSONValue];
    NSArray *resultados=[root objectForKey:@"results"];
    
    self.estadiosFutbolArray=[[NSMutableArray alloc] initWithCapacity:[resultados count]];
    

    
    for (NSDictionary *fila in resultados){
        // Aquí obtenemos todos los valores que nos interesen del JSON y
        // los trataremos como consideremos necesario
        NSString *nombreEstadio=[fila objectForKey:@"nombreEstadio"];
        NSString *ciudad=[fila objectForKey:@"ciudad"];
        NSNumber *latitud=[fila objectForKey:@"latitud"];
        NSNumber *longitud=[fila objectForKey:@"longitud"];
        // Aquí crearemos nuestro objeto EstadioFutbol y lo añadiremos
        // a la base de datos y al array para la tableview controller
        [self.estadiosFutbolArray addObject:[EstadioFutbol objetoEstadioFutbol:nombreEstadio ciudad:ciudad latitud:latitud longitud:longitud]];
        
        
        EstadioFutbol *estadioAux=[EstadioFutbol objetoEstadioFutbol:nombreEstadio ciudad:ciudad latitud:latitud longitud:longitud];
        [self.estadiosFutbolArray addObject:estadioAux];
        
        if([strFechaActualizacion isEqualToString:@""]){
            [self aniadirEstadioBBDD:estadioAux];
            //NSString *fechaActualizacion=[fila objectForKey:@"createdAt"];
            //NSLog(@"creada añadirla : %@",fechaActualizacion);
        }else{            
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [formatter setLocale:[NSLocale systemLocale]];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
            NSString *strFechaCreacion=[fila objectForKey:@"createdAt"];
            NSDate * fechaCreacion = [formatter dateFromString:strFechaCreacion];
            
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
            NSDate *fechaActualizacion = [dateFormatter dateFromString:strFechaActualizacion]; 
            
            
            if ([fechaActualizacion laterDate:fechaCreacion] == fechaCreacion){
                NSLog(@"creada verificar si hay que añadir : %@",fechaCreacion);
                [self aniadirEstadioBBDD:estadioAux];
            }
            
        }        
        

        CLLocationCoordinate2D coord;
        coord.latitude=[latitud doubleValue];
        coord.longitude=[longitud doubleValue];
        MiAnotacion * anotacion=[[MiAnotacion alloc] initWithCoordinate:coord title:nombreEstadio subtitle:ciudad];

        
        [mapa addAnnotation:anotacion];
        
        NSDate *fechaEjecucion=[NSDate date];
        NSString *sFechaEjecucion=[NSString stringWithFormat:@"%@",fechaEjecucion];
        [userDefaults setValue:sFechaEjecucion forKey:@"fechaActualizacion_preference"];        
        

    }
    
    NSLog(@"Numero de estadios: %d",[self.estadiosFutbolArray count]);
    

       
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 40.453042;
    zoomLocation.longitude= -3.688294;
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 600000, 600000);
    // 3
    MKCoordinateRegion adjustedRegion = [mapa regionThatFits:viewRegion];                
    // 4
    [mapa setRegion:adjustedRegion animated:YES];      
    
    

    
}

-(void)traerDatosInternet:(NSString *)mensajeCarga
{
    NSURL *url=[NSURL URLWithString:@"https://api.parse.com/1/classes/EstadioFutbol"];
    
    ASIHTTPRequest *_request=[ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *request = _request;
    request.requestMethod = @"GET";
    [request addRequestHeader:@"X-Parse-Application-Id" value:@"SC8IkKy0dRTzT9dWixDZ7x1Vtly3sRpNj3P8rqK3"];
    [request addRequestHeader:@"X-Parse-REST-API-Key" value:@"SC1Zi7a9dQUhUwjE52q2WUfbvCT4Il7z5WcyP17Q"];
    [request setDelegate:self];    
    
    [request setCompletionBlock: ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSString *responseString=[request responseString];
        
        // Este método irá en el View Controller y se llamará como queramos
        
        [self tratarDatosNube: responseString];
    }];  
    
    
    [request setFailedBlock: ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSError *error=[request error];
        // Tratar el error
        NSLog(@"Error %@",error.description);
        UIAlertView *alerta=[[UIAlertView alloc] initWithTitle:@"Error" message:@"Se ha producido un error al intentar cargar los datos. Inténtelo más tarde." delegate:self cancelButtonTitle:@"Cerrar" otherButtonTitles:nil, nil];
        [alerta show];
    }];     
    
    [request startAsynchronous];
    
    // Indicador de progreso aquí se muestra
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];    
    hud.labelText = @"Cargando estados";        
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[MiAnotacion class]]){        
        MKPinAnnotationView*    pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        
        if (!pinView)
        {
            pinView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.enabled = YES;
            pinView.canShowCallout = YES;
            pinView.animatesDrop=YES;

            
        }
        else
            pinView.annotation = annotation;
        
        return pinView;
        
    }
    
    
    
    return nil;
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSLog(@"fechaActualizacion_preference -->%@",[userDefaults objectForKey:@"fechaActualizacion_preference"]);    
    
    if([userDefaults boolForKey:@"demo_preference"]==YES){
        [self cargarDatosDemo];
    }else{
        if([userDefaults boolForKey:@"sincronizar_preference"]==YES){
            [self traerDatosInternet:@"Cargando Datos"];
        }else{
            // Obtener datos de la BBDD
            NSLog(@"Obtenemos los datos de local");
            
            CoreDataManager *coreDataManager=[CoreDataManager sharedInstance];
            NSManagedObjectContext *contexto=[coreDataManager managedObjectContext];
            NSFetchRequest *request=[[NSFetchRequest alloc] init];
            NSEntityDescription *entity=[NSEntityDescription entityForName:@"EstadioFutbol" inManagedObjectContext:contexto];
            [request setEntity:entity];
            NSError *error;
            NSMutableArray *estadiosBBDD=[[contexto executeFetchRequest:request error:&error] mutableCopy];
            
            self.estadiosFutbolArray=[[NSMutableArray alloc] initWithCapacity:[estadiosBBDD count]];
            
            for (NSManagedObject *estadioBBDD in estadiosBBDD) {
                
                EstadioFutbol *estadio=[EstadioFutbol objetoEstadioFutbol:[estadioBBDD valueForKey:@"nombreEstadio"] ciudad:[estadioBBDD valueForKey:@"ciudad"] latitud:[estadioBBDD valueForKey:@"latitud"] longitud:[estadioBBDD valueForKey:@"longitud"]];
                [self.estadiosFutbolArray addObject:estadio];
            }
            
            
            for (EstadioFutbol *estadio in self.estadiosFutbolArray) {
                CLLocationCoordinate2D coord;
                coord.latitude=[estadio.latitud doubleValue];
                coord.longitude=[estadio.longitud doubleValue];
                MiAnotacion * anotacion=[[MiAnotacion alloc] initWithCoordinate:coord title:estadio.nombreEstadio subtitle:estadio.ciudad];
                
                
                [mapa addAnnotation:anotacion];
            }
            
            CLLocationCoordinate2D zoomLocation;
            zoomLocation.latitude = 40.453042;
            zoomLocation.longitude= -3.688294;
            // 2
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 600000, 600000);
            // 3
            MKCoordinateRegion adjustedRegion = [mapa regionThatFits:viewRegion];                
            // 4
            [mapa setRegion:adjustedRegion animated:YES];             

            
        }
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
