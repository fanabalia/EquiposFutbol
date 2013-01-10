//
//  EstadioFutbolTableViewController.h
//  EquiposFutbol
//
//  Created by macbook on 27/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EstadioFutbolTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>{
    NSMutableArray *estadiosFutbolArray;
    NSMutableArray *filteredEstadiosFutbolArray;
    IBOutlet UISearchBar *estadiosFutbolSearchBar;
}

@property (strong,nonatomic) NSMutableArray *estadiosFutbolArray;
@property (strong,nonatomic) NSMutableArray *filteredEstadiosFutbolArray;
@property (strong,nonatomic) IBOutlet UISearchBar *estadiosFutbolSearchBar;

-(IBAction)abrirBusqueda:(id)sender;
-(IBAction)refrescar:(id)sender;

@end
