LEN = 50 ;
DIM = 2 ;

module menger_hole( m_len, len, dim ) {
    cube( [ m_len + 1,
            len / 3,
            len / 3 ],
           center = true ) ;
    cube( [ len / 3,
            m_len + 1,
            len / 3 ],
           center = true ) ;
    cube( [ len / 3,
            len / 3,
            m_len + 1 ],
           center = true ) ;
    if( 0 < dim ) {
        for( x = [ -1 : 1 ] ) {
            for( y = [ -1 : 1 ] ) {
                for( z = [ -1 : 1 ] ) {
                    if( ( x != 0 && y != 0 ) ||
                        ( x != 0 && z != 0 ) ||
                        ( y != 0 && z != 0 ) ) {
                        translate( [ x * len / 3,
                                     y * len / 3,
                                     z * len / 3 ] ) {
                                       menger_hole( m_len, len / 3, dim - 1 ) ;
                        }
                    }
                }
            }
        }
    }
}

module menger_sponge( len, dim ) {
    difference() {
        cube( size = len, center = true ) ;
        menger_hole( len, len, dim ) ;
    }
}

menger_sponge( LEN, DIM ) ;
