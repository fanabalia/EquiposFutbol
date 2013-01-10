//
//  EstadioFutbolTableViewController.m
//  EquiposFutbol
//
//  Created by macbook on 27/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EstadioFutbolTableViewController.h"
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "SBJSON.h"
#import "EstadioFutbol.h"
#import "EstadioFutbolDetalleViewController.h"
#import "CoreDataManager.h"

@implementation EstadioFutbolTableViewController

@synthesize estadiosFutbolArray;
@synthesize filteredEstadiosFutbolArray;
@synthesize estadiosFutbolSearchBar;


-(void)cargarDatosDemo
{
    NSLog(@"Cargar datos demo");
    NSMutableArray *datosEstadiosArray=[[NSMutableArray alloc] initWithCapacity:2];
    [datosEstadiosArray addObject:[EstadioFutbol objetoEstadioFutbol:@"Santiago Bernabeu" ciudad:@"Madrid" latitud:[[NSNumber alloc] initWithDouble:40.453042] longitud:[[NSNumber alloc] initWithDouble:-3.688294]]];
    [datosEstadiosArray addObject:[EstadioFutbol objetoEstadioFutbol:@"Nou Camp" ciudad:@"Barcelona" latitud:[[NSNumber alloc] initWithDouble:41.380887] longitud:[[NSNumber alloc] initWithDouble:2.122826]]];   
    self.estadiosFutbolArray=datosEstadiosArray;
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
        
        
    }
    
    NSLog(@"Numero de estadios: %d",[self.estadiosFutbolArray count]);
    
    self.filteredEstadiosFutbolArray = [NSMutableArray arrayWithCapacity:[estadiosFutbolArray count]];
    
    [self.tableView reloadData];
    
    NSDate *fechaEjecucion=[NSDate date];
    NSString *sFechaEjecucion=[NSString stringWithFormat:@"%@",fechaEjecucion];
    [userDefaults setValue:sFechaEjecucion forKey:@"fechaActualizacion_preference"];
    
    
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
        
        NSLog(@"Error %@",error.description);
        UIAlertView *alerta=[[UIAlertView alloc] initWithTitle:@"Error" message:@"Se ha producido un error al intentar cargar los datos. Inténtelo más tarde." delegate:self cancelButtonTitle:@"Cerrar" otherButtonTitles:nil, nil];
        [alerta show];        
        
    }];     
    
    [request startAsynchronous];    
    
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];    
    hud.labelText = mensajeCarga;    
}





-(IBAction)abrirBusqueda:(id)sender {
    [estadiosFutbolSearchBar becomeFirstResponder];
}

-(IBAction)refrescar:(id)sender
{
    [self traerDatosInternet:@"Refrescando Datos"];
}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSLog(@"fechaActualizacion_preference -->%@",[userDefaults objectForKey:@"fechaActualizacion_preference"]);

    
    
    estadiosFutbolSearchBar.placeholder=@"Buscar";

    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + estadiosFutbolSearchBar.bounds.size.height;
    self.tableView.bounds = newBounds;    
    
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
            
            [self.tableView reloadData];
            
        }
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [filteredEstadiosFutbolArray count];
    } else {
        return [estadiosFutbolArray count];
    }    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Celda";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    EstadioFutbol  *estadioFutbol = nil;

    if (tableView == self.searchDisplayController.searchResultsTableView) {
        estadioFutbol = [filteredEstadiosFutbolArray objectAtIndex:indexPath.row];
    } else {
        estadioFutbol = [estadiosFutbolArray objectAtIndex:indexPath.row];
    }    
    
    // Configure the cell
    cell.textLabel.text = estadioFutbol.nombreEstadio;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.

     EstadioFutbolDetalleViewController *detailViewController = [[EstadioFutbolDetalleViewController alloc] initWithNibName:@"EstadioFutbolDetalleViewController" bundle:nil];
    
    EstadioFutbol  *estadioFutbol = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        estadioFutbol = [filteredEstadiosFutbolArray objectAtIndex:indexPath.row];
    } else {
        estadioFutbol = [estadiosFutbolArray objectAtIndex:indexPath.row];
    }  
    detailViewController.estadioFutbol=estadioFutbol;    
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];

}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [self.filteredEstadiosFutbolArray removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.nombreEstadio contains[c] %@",searchText];
    filteredEstadiosFutbolArray = [NSMutableArray arrayWithArray:[estadiosFutbolArray filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    for (UIView* v in self.searchDisplayController.searchResultsTableView.subviews) {
        if ([v isKindOfClass: [UILabel class]] && 
            [[(UILabel*)v text] isEqualToString:@"No Results"]) {
            [(UILabel*)v setText:@"No hay resultados"];
            break;
        }
    }    
    
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
        
    
    return YES;
}

@end
