A2 <- lapply(1:300, function(t) matrix(rnorm(100000), nrow = 1000, ncol = 10))

lplyretListListMat <- "using Eigen::MatrixXd;
                       using Eigen::VectorXd;
                       typedef Eigen::Map<Eigen::MatrixXd> MapMatd;
                       List A(AA);
                       int listSize = A.size();
                       List outList;
                       List subList;
                       for (int i = 0; i < listSize; i++)
                       {
                         MapMatd subMat(as<MapMatd >(A[i]));
                         int sublistSize = subMat.rows();   
                         int ncol = subMat.cols();
                         for (int j = 0; j < sublistSize; j++)
                         {  
                           VectorXd currRow(ncol);
                           for (int k = 0; k < ncol; k++)
                           {
                             currRow[k] = subMat.coeff(j,k);
                           }      
                           subList[String(j)] = currRow * currRow.transpose();
                         }
                         outList[String(i)] = subList; 
                       }
                       return outList;
                       "

retListListMatC <- cxxfunction(signature(AA = "List"), lplyretListListMat, plugin = "RcppEigen")

test1 <- function(A) lapply(apply(A, 1, function(t) list(tcrossprod(t))), "[[", 1)

system.time(lapply(A2, function(t) test1(t)))
system.time(retListListMatC(A2))
