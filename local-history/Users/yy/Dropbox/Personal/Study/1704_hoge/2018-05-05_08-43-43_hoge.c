#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <complex.h>
#include <string.h>
#include <time.h>
#include <fftw3.h>
#undef complex
typedef _Complex double complex;
#define PI M_PI


// マクロ定義


#define FFTSIZE 128
/* #define PATH 3 */

/* #define TRIAL 1000000 */
#define TRIAL 5000000

#define POWER_ALICE 1.0
#define POWER_BOB   1.0

/* #define ANTENNA_ALICE 2 */
#define ANTENNA_ALICE 3
/* #define ANTENNA_ALICE 4 */
#define ANTENNA_BOB   2
/* #define ANTENNA_BOB   3 */
/* #define ANTENNA_BOB   4 */
/* #define ANTENNA_BOB   6 */
/* #define ANTENNA_BOB   8 */

#define PILOT_ALICE ANTENNA_ALICE
#define PILOT_BOB ANTENNA_BOB


#define cabs_2( c ) ( cabs( c ) * cabs( c ) )
#define abs_2( d ) ( (double) ( d ) * ( d ) )



// 色
#define RESET      "\033[0m"
#define GREEN      "\033[32m"
#define YELLOW     "\033[33m"
#define OFFWHITE   "\033[37m"
#define GRAY       "\033[1m\033[30m"
#define ORANGE     "\033[1m\033[31m"
#define LIGHTGREEN "\033[1m\033[32m"
#define PURPLE     "\033[1m\033[34m"
#define PINK       "\033[1m\033[35m"
#define LIGHTBLUE  "\033[1m\033[36m"




void GaussianGeneration(complex *gaussian, double sigma, int count);
void InverseMatrix( complex **matrixBef, complex **matrixAft, int rowColumn );
void HermitianTranspose( complex **matrixBef, complex **matrixAft, int row, int column );
void Trace(complex **matrix, int rowColumn, complex *trace);
void FFT(complex *time, complex *frequency, int ofdmSymbolCount);
void IFFT(complex *frequency, complex *time, int ofdmSymbolCount);

static fftw_complex *fftw_time;
static fftw_complex *fftw_frequency;
static fftw_plan fftPlan;
static fftw_plan ifftPlan;



// メイン関数
int main(void){


	// fftw用のメモリの動的割り当て
	fftw_time = fftw_malloc( sizeof(fftw_complex) * FFTSIZE );
	fftw_frequency = fftw_malloc( sizeof(fftw_complex) * FFTSIZE );
	fftPlan = fftw_plan_dft_1d(FFTSIZE, fftw_time, fftw_frequency, FFTW_FORWARD, FFTW_MEASURE );
	ifftPlan = fftw_plan_dft_1d(FFTSIZE, fftw_frequency, fftw_time, FFTW_BACKWARD, FFTW_MEASURE );



	int trial;
	int i, j, k;

	/* double sigma = sqrt( 10.0 / 2.0 ); */
	double sigma = sqrt( 1.0 / 2.0 );


	/* double correlation = 0.0; */
	double correlation = 1.0;
	/* double correlation = 0.5; */
 	/* double correlation = 0.1; */
	/* double correlation = 0.2; */

	printf( "correlation = %f\n", correlation );

	double coefficient = sqrt( 1 - abs_2( correlation ) ) * sigma;


	complex **Hab = malloc( sizeof(complex *) * ANTENNA_BOB );
	for( i = 0; i < ANTENNA_BOB; i++ ){
		Hab[i] = malloc( sizeof(complex) * ANTENNA_ALICE );
	}
	complex **Hba = malloc( sizeof(complex *) * ANTENNA_ALICE );
	for( i = 0; i < ANTENNA_ALICE; i++ ){
		Hba[i] = malloc( sizeof(complex) * ANTENNA_BOB );
	}
	complex **H = malloc( sizeof(complex *) * ANTENNA_ALICE );
	for( i = 0; i < ANTENNA_ALICE; i++ ){
		H[i] = malloc( sizeof(complex) * ANTENNA_ALICE );
	}
	complex **HH = malloc( sizeof(complex *) * ANTENNA_ALICE );
	for( i = 0; i < ANTENNA_ALICE; i++ ){
		HH[i] = malloc( sizeof(complex) * ANTENNA_ALICE );
	}
	complex **RH = malloc( sizeof(complex *) * ANTENNA_ALICE );
	for( i = 0; i < ANTENNA_ALICE; i++ ){
		RH[i] = calloc( ANTENNA_ALICE, sizeof(complex) );
	}
	complex **Rh = malloc( sizeof(complex *) * ANTENNA_ALICE );
	for( i = 0; i < ANTENNA_ALICE; i++ ){
		Rh[i] = calloc( ANTENNA_ALICE, sizeof(complex) );
	}

	complex sum;

	complex *noise = malloc( sizeof(complex) * ANTENNA_BOB );

    if (sum/2==0) {
        return 0;
    }



	for( trial = 0; trial < TRIAL; trial++ ){


		for( i = 0; i < ANTENNA_BOB; i++ ){
			GaussianGeneration( Hab[i], sigma, ANTENNA_ALICE );
		}

		/* HermitianTranspose( Hab, Hba, ANTENNA_BOB, ANTENNA_ALICE ); */

		// 相関をもたせる
		for( i = 0; i < ANTENNA_ALICE; i++ ){
			GaussianGeneration( noise, 1.0, ANTENNA_BOB );
			for( j = 0; j < ANTENNA_BOB; j++ ){
				Hba[i][j] = correlation * Hab[j][i] + coefficient * noise[j];
			}
		}

		/* for( i = 0; i < ANTENNA_ALICE; i++ ){ */
		/* 	for( j = 0; j < ANTENNA_BOB; j++ ){ */
		/* 		Hba[i][j] *= sqrt( 2.0 ); */
		/* 		/\* Hba[i][j] *= sqrt( 8.1 ); *\/ */
		/* 	} */
		/* } */

		for( i = 0; i < ANTENNA_ALICE; i++ ){
			for( j = 0; j < ANTENNA_ALICE; j++ ){
				sum = 0;
				for( k = 0; k < ANTENNA_BOB; k++ ){
					RH[i][j] += Hba[i][k] * Hab[k][j];
					sum += Hba[i][k] * Hab[k][j];
					/* if( i == j ){ */
					/* 	printf( "%f %f   ", creal( Hba[i][k] ), cimag( Hba[i][k] ) ); */
					/* 	printf( "%f %f\n", creal( Hab[k][j] ), cimag( Hab[k][j] ) ); */
					/* } */
				}
				Rh[i][j] += cabs_2( sum );
			}
		}


		/* for( i = 0; i < ANTENNA_ALICE; i++ ){ */
		/* 	GaussianGeneration( Hba[i], sigma2, ANTENNA_BOB ); */
		/* } */

		/* for( i = 0; i < ANTENNA_ALICE; i++ ){ */
		/* 	for( j = 0; j < ANTENNA_ALICE; j++ ){ */
		/* 		H[i][j] = 0; */
		/* 		for( k = 0; k < ANTENNA_BOB; k++ ){ */
		/* 			H[i][j] += Hba[i][k] * Hab[k][j]; */
		/* 		} */
		/* 	} */
		/* } */
		/* HermitianTranspose( H, HH, ANTENNA_ALICE, ANTENNA_ALICE ); */


		/* for( i = 0; i < ANTENNA_ALICE; i++ ){ */
		/* 	for( j = 0; j < ANTENNA_ALICE; j++ ){ */
		/* 		/\* sum = 0; *\/ */
		/* 		for( k = 0; k < ANTENNA_ALICE; k++ ){ */
		/* 			RH[i][j] += HH[i][k] * H[k][j]; */
		/* 			/\* sum      += HH[i][k] * H[k][j]; *\/ */
		/* 		} */
		/* 		/\* Rh[i][j] += cabs_2( sum ); *\/ */
		/* 	} */
		/* } */

		fprintf( stderr, " TRIAL = %d\r", trial );


	} // トライアル

	for( i = 0; i < ANTENNA_ALICE; i++ ){
		for( j = 0; j < ANTENNA_ALICE; j++ ){
			RH[i][j] /= TRIAL;
			Rh[i][j] /= TRIAL;
			/* R [i][j] /= TRIAL; */
		}
	}


	for( i = 0; i < ANTENNA_ALICE; i++ ){
		for( j = 0; j < ANTENNA_ALICE; j++ ){
			printf( "%f %f\n", creal( RH[i][j] ), cimag( RH[i][j] ) );
		}
	}

	putchar('\n');
	for( i = 0; i < ANTENNA_ALICE; i++ ){
		for( j = 0; j < ANTENNA_ALICE; j++ ){
			printf( "%f %f\n", creal( Rh[i][j] ), cimag( Rh[i][j] ) );
		}
	}







	// -----------------------------------------------------------------

	/* double sigma = sqrt( 5.0 / 2.0 ); */

	/* complex **noise = malloc( sizeof(complex *) * ANTENNA_BOB ); */
	/* for( i = 0; i < ANTENNA_BOB; i++ ){ */
	/* 	noise[i] = malloc( sizeof(complex) * PILOT_ALICE ); */
	/* } */
	/* complex **noiseH = malloc( sizeof(complex *) * PILOT_ALICE ); */
	/* for( i = 0; i < PILOT_ALICE; i++ ){ */
	/* 	noiseH[i] = malloc( sizeof(complex) * ANTENNA_BOB ); */
	/* } */
	/* complex **noisenoise = malloc( sizeof(complex *) * ANTENNA_BOB ); */
	/* for( i = 0; i < ANTENNA_BOB; i++ ){ */
	/* 	noisenoise[i] = calloc( ANTENNA_BOB, sizeof(complex) ); */
	/* } */


	/* for( trial = 0; trial < TRIAL; trial++ ){ */


	/* 	for( i = 0; i < ANTENNA_BOB; i++ ){ */
	/* 		GaussianGeneration( noise[i], sigma, PILOT_ALICE ); */
	/* 	} */

	/* 	HermitianTranspose( noise, noiseH, ANTENNA_BOB, PILOT_ALICE ); */

	/* 	for( i = 0; i < ANTENNA_BOB; i++ ){ */
	/* 		for( j = 0; j < ANTENNA_BOB; j++ ){ */
	/* 			for( k = 0; k < PILOT_ALICE; k++ ){ */
	/* 				noisenoise[i][j] += noiseH[i][k] * noise[k][j]; */
	/* 			} */
	/* 		} */
	/* 	} */


	/* 	fprintf( stderr, " TRIAL = %d\r", trial ); */

	/* } */


	/* for( i = 0; i < ANTENNA_BOB; i++ ){ */
	/* 	for( j = 0; j < ANTENNA_BOB; j++ ){ */
	/* 		noisenoise[i][j] /= trial; */
	/* 		printf( "%f %f\n", creal( noisenoise[i][j] ), cimag( noisenoise[i][j] ) ); */
	/* 	} */
	/* } */



	/* complex **Hab = malloc( sizeof(complex *) * ANTENNA_BOB ); */
	/* for( i = 0; i < ANTENNA_BOB; i++ ){ */
	/* 	Hab[i] = malloc( sizeof(complex) * ANTENNA_ALICE ); */
	/* } */
	/* complex **Hba = malloc( sizeof(complex *) * ANTENNA_ALICE ); */
	/* for( i = 0; i < ANTENNA_ALICE; i++ ){ */
	/* 	Hba[i] = malloc( sizeof(complex) * ANTENNA_BOB ); */
	/* } */
	/* complex **Hab = malloc( sizeof(complex *) * ANTENNA_ALICE ); */
	/* for( i = 0; i < ANTENNA_ALICE; i++ ){ */
	/* 	Hab[i] = malloc( sizeof(complex) * ANTENNA_ALICE ); */
	/* } */
	/* complex **Hba = malloc( sizeof(complex *) * ANTENNA_ALICE ); */
	/* for( i = 0; i < ANTENNA_ALICE; i++ ){ */
	/* 	Hba[i] = malloc( sizeof(complex) * ANTENNA_ALICE ); */
	/* } */
	/* complex **RH = malloc( sizeof(complex *) * ANTENNA_ALICE ); */
	/* for( i = 0; i < ANTENNA_ALICE; i++ ){ */
	/* 	RH[i] = calloc( ANTENNA_ALICE, sizeof(complex) ); */
	/* } */


	/* for( trial = 0; trial < TRIAL; trial++ ){ */

	/* 	for( i = 0; i < ANTENNA_BOB; i++ ){ */
	/* 		GaussianGeneration( Hab[i], sigma, ANTENNA_ALICE ); */
	/* 	} */
	/* 	for( i = 0; i < ANTENNA_ALICE; i++ ){ */
	/* 		GaussianGeneration( Hba[i], sigma, ANTENNA_BOB ); */
	/* 	} */

	/* 	for( i = 0; i < ANTENNA_ALICE; i++ ){ */
	/* 		for( j = 0; j < ANTENNA_ALICE; j++ ){ */
	/* 			Hab[i][j] = 0.0; */
	/* 			for( k = 0; k < ANTENNA_BOB; k++ ){ */
	/* 				Hab[i][j] += Hba[i][k] * Hab[k][j]; */
	/* 			} */
	/* 		} */
	/* 	} */

	/* 	HermitianTranspose( Hab, Hba, ANTENNA_ALICE, ANTENNA_ALICE ); */

	/* 	for( i = 0; i < ANTENNA_ALICE; i++ ){ */
	/* 		for( j = 0; j < ANTENNA_ALICE; j++ ){ */
	/* 			for( k = 0; k < ANTENNA_ALICE; k++ ){ */
	/* 				RH[i][j] += Hba[i][k] * Hab[k][j]; */
	/* 			} */
	/* 		} */
	/* 	} */


	/* 	fprintf( stderr, " TRIAL = %d\r", trial ); */

	/* } */

	/* for( i = 0; i < ANTENNA_ALICE; i++ ){ */
	/* 	for( j = 0; j < ANTENNA_ALICE; j++ ){ */
	/* 		RH[i][j] /= trial; */
	/* 	} */
	/* } */

	/* complex tra; */
	/* Trace( RH, ANTENNA_ALICE, &tra ); */

	/* for( i = 0; i < ANTENNA_ALICE; i++ ){ */
	/* 	for( j = 0; j < ANTENNA_ALICE; j++ ){ */
	/* 		printf( "%f %f\n", creal( RH[i][j] ), cimag( RH[i][j] ) ); */
	/* 	} */
	/* } */


	/* printf( "trace = %f %f\n", creal( tra ), cimag( tra ) ); */




	return 0;

}







// 与えられた標準偏差に則ったガウス関数を生み出す
void GaussianGeneration(complex *gaussian, double sigma, int count){

	int i;
    double u1, u2;
	double env, ang;

    for( i = 0; i < count; i++ ){

		do{
			u1 = (double) random() / RAND_MAX;
			u2 = (double) random() / RAND_MAX;
		} while( u1 * u2 == 0 );

		env = sqrt( -2.0 * log(u1) ) * sigma;
		ang = 2.0 * PI * u2;

		gaussian[i] = env * cos(ang) + I * env * sin(ang);
    }

}





// 逆行列
void InverseMatrix( complex **matrixBef, complex **matrixAft, int rowColumn ){

	int i, j, k;
	complex inverse;
	int roopCnt;
	int rowColumn2 = rowColumn * 2;

	// 作業領域 (掃き出し法)
	complex **work = malloc( sizeof(complex *) * rowColumn );
	for( i = 0; i < rowColumn; i++ ){
		work[i] = malloc( sizeof(complex) * rowColumn2 );
	}
	// 作業領域の初期化
	for( i = 0; i < rowColumn; i++ ){
		for( j = 0; j < rowColumn; j++ ){
			work[i][j] = matrixBef[i][j];
		}
		for( j = rowColumn; j < rowColumn2; j++ ){
			work[i][j] = ( j == i + rowColumn ) ? 1.0 : 0.0;
		}
	}

	// 入れ替え用
	complex *row = malloc( sizeof(complex) * rowColumn );


	// 掃き出す
	for( i = 0; i < rowColumn; i++ ){

		/* printf("i=%d : phase 00\n", i); */
		/* for( int i = 0; i < rowColumn; i++ ){ */
		/* 	for( int j = 0; j < rowColumn2; j++ ){ */
		/* 		printf("(%5.2f %5.2f) ", creal( work[i][j] ), cimag( work[i][j] )); */
		/* 	} */
		/* 	putchar('\n'); */
		/* }putchar('\n'); */

		// i行i列目が0ならi行以下をループさせる
		roopCnt = 0;
		while( ! work[i][i] && roopCnt < rowColumn - i ){
			for( j = 0; j < rowColumn2; j++ ){
				// 一時コピー
				for( k = i; k < rowColumn; k++ ){
					row[k] = work[k][j];
				}
				// 入れ替え
				for( k = i; k < rowColumn; k++ ){
					work[k][j] = ( k + 1 == rowColumn ) ? row[i] : row[ k + 1 ];
				}
			}
			roopCnt++;
		}

		// i列目が全てゼロで逆行列は求められない場合に異常終了
		if( roopCnt == rowColumn - i ){
			printf( "Determinant is Zero\n" );
			return;
		}

		/* printf("i=%d : phase 01\n", i); */
		/* for( int i = 0; i < rowColumn; i++ ){ */
		/* 	for( int j = 0; j < rowColumn2; j++ ){ */
		/* 		printf("(%5.2f %5.2f) ", creal( work[i][j] ), cimag( work[i][j] )); */
		/* 	} */
		/* 	putchar('\n'); */
		/* }putchar('\n'); */

		// i行i列目を1にする
		inverse = 1.0 / work[i][i];
		for( j = 0; j < rowColumn2; j++ ){
			work[i][j] *= inverse;
		}

		/* printf("i=%d : phase 02\n", i); */
		/* for( int i = 0; i < rowColumn; i++ ){ */
		/* 	for( int j = 0; j < rowColumn2; j++ ){ */
		/* 		printf("(%5.2f %5.2f) ", creal( work[i][j] ), cimag( work[i][j] )); */
		/* 	} */
		/* 	putchar('\n'); */
		/* }putchar('\n'); */

		// 他の行のi列目を0にする
		for( j = 0; j < rowColumn; j++ ){
			if( j != i ){		/* i行は必要ない */
				inverse = work[j][i];
				for( k = 0; k < rowColumn2; k++ ){
					work[j][k] -= work[i][k] * inverse;
				}
			}
		}

		/* printf("i=%d : phase 03\n", i); */
		/* for( int i = 0; i < rowColumn; i++ ){ */
		/* 	for( int j = 0; j < rowColumn2; j++ ){ */
		/* 		printf("(%5.2f %5.2f) ", creal( work[i][j] ), cimag( work[i][j] )); */
		/* 	} */
		/* 	putchar('\n'); */
		/* }putchar('\n'); */

	}

	// 出力
	for( i = 0; i < rowColumn; i++ ){
		for( j = 0; j < rowColumn; j++ ){
			matrixAft[i][j] = work[i][ j + rowColumn ];
		}
	}

	// メモリ解放
	for( i = 0; i < rowColumn; i++ ){
		free( work[i] );
	}
	free( work );
	free( row );

}





// エルミート転置
void HermitianTranspose( complex **matrixBef, complex **matrixAft, int row, int column ){

	int i, j;

	for( i = 0; i < column; i++ ){
		for( j = 0; j < row; j++ ){
			matrixAft[i][j] = conj( matrixBef[j][i] );
		}
	}

}





// トレース
void Trace( complex **matrix, int rowColumn, complex *trace ){

	int i;
	*trace = 0.0;

	for( i = 0; i < rowColumn; i++ ){
		*trace += matrix[i][i];
	}

}




// 高速フーリエ変換
void FFT(complex *time, complex *frequency, int ofdmSymbolCount){

	int i;
	size_t size = sizeof(complex) * FFTSIZE;
	double scale = 1.0 / sqrt(FFTSIZE);
	int symbolLen = ofdmSymbolCount * FFTSIZE;

	for( i = 0; i < ofdmSymbolCount; i++ ){
		memcpy(fftw_time, &time[i * FFTSIZE], size);
		fftw_execute(fftPlan);
		memcpy(&frequency[i * FFTSIZE], fftw_frequency, size);
	}

	for( i = 0; i < symbolLen; i++ ){
		frequency[i] *= scale;
	}
}





// 高速逆フーリエ変換
void IFFT(complex *frequency, complex *time, int ofdmSymbolCount){

	int i;
	size_t size = sizeof(complex) * FFTSIZE;
	double scale = 1.0 / sqrt(FFTSIZE);
	int symbolLen = ofdmSymbolCount * FFTSIZE;

	for( i = 0; i < ofdmSymbolCount; i++ ){
		memcpy(fftw_frequency, &frequency[i * FFTSIZE], size);
		fftw_execute(ifftPlan);
		memcpy(&time[i * FFTSIZE], fftw_time, size);
	}

	for( i = 0; i < symbolLen; i++ ){
		time[i] *= scale;
	}
}
