!  *********************************************************************
!  *                                                                   *
!  *                        subroutine intr2d                          *
!  *                                                                   *
!  *********************************************************************
!  Mixed Precision Version 2.31
!  Written by Gordon A. Fenton, TUNS, Aug. 26, 1992
!  Latest Update: Jun 9, 1999
!
!  PURPOSE  creates the parameter matrices required for the interior cell
!           subdivision of LAS2G.
!
!  Requires:
!   1) from libGAFsim:	DSIFA, DSISL, DCHOL2, DAXPY, DSWAP, DDOT, IDAMAX
!
!    n    is the rank of [CC][CC^T]. It can be either n = 3 for the 2-D case or
!         n = 7 for the 3-D case.
!    mi   is the mapping from the global covariance matrix `R' into the local
!         `interior' covariance matrix (in the 2-D case, this is 1-to-1).
!
!  REVISION HISTORY:
!  2.31	replaced dummy dimensions with a (*) for GNU's compiler (Jun 9/99)
!-----------------------------------------------------------------------------
      subroutine intr2d( R, ir, B, ib, S, is, CI, n, AI, mi, iout, tol )
      real*8 R(ir,*), B(ib,*), S(is,*)
      real*8 RI(9,9), DA(9), BB(7,7)
      real CI(*), AI(9,*)
      integer mi(*), indx(9)

   1  format(a,a,a)
   2  format(a,e13.4)
!							extract R
      do 10 j = 1, 9
         do 10 i = 1, j
            RI(i,j) = R(mi(i),mi(j))
  10  continue
!							factorize R
      call dsifa( RI, 9, 9, indx, ierr )
      if( ierr .ne. 0 ) then
         write(iout,1)'Error: unable to factorize interior covariance matrix in INTR2D.'
         stop
      endif
!							make a copy of S
      do 50 j = 1, n
         do 20 i = 1, 9
            DA(i) = S(mi(i),j)
  20     continue
!							and solve for A
         call dsisl( RI, 9, 9, indx, DA )
!							store in real*4
         do 30 i = 1, 9
            AI(i,j) = DA(i)
  30     continue
!							update B
         do 40 i = 1, j
            BB(i,j) = B(i,j)                                               &
                    - S(mi(1),i)*DA(1)-S(mi(2),i)*DA(2)-S(mi(3),i)*DA(3)   &
                    - S(mi(4),i)*DA(4)-S(mi(5),i)*DA(5)-S(mi(6),i)*DA(6)   &
                    - S(mi(7),i)*DA(7)-S(mi(8),i)*DA(8)-S(mi(9),i)*DA(9)    
  40     continue
  50  continue
!							Cholesky Decomposition
      call dchol2( BB, 7, n, rerr )
      if( rerr .gt. tol ) then
         write(iout,1)'Intr2d: Cholesky decomposition of interior covariance matrix BB'
         write(iout,2)'        has maximum relative error of ',rerr
      endif
!							store in real*4
      ii = 0
      do 60 j = 1, n
      do 60 i = 1, j
         ii = ii + 1
         CI(ii) = BB(i,j)
  60  continue

      return
      end
