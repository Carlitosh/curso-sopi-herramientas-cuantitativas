a1 <- c(16,18,20,11,17,8,14,10,4,7)
b1 <- c(13,13,13,12,12,11,11,10,9,9)
a2 <- c(8,9,6,8,5,7,4,6,4,3)
b2 <- c(8,7,7,6,5,5,4,3,2,2)
a3 <- c(19,19,17,17,16,14,13,13,11,11)
b3 <- c(6,3,8,1,4,5,8,1,6,3)

a1 <- c(11,10,14)
b1 <- c(12,10,11)
a3 <- c(17,16,14,13)
b3 <- c(8,4,5,1)


m1 <- as.vector(c(mean(a1), mean(b1)))
m2 <- as.vector(c(mean(a2), mean(b2)))
m3 <- as.vector(c(mean(a3), mean(b3)))

p1 = 0.048
p2 = 0.042
p3 = 0.910


df1 <- as.data.frame(a1)
df1$b1 <- b1
c1 <- cov(df1)
df2 <- as.data.frame(a2)
df2$b2 <- b2
c2 <- cov(df2)
df3 <- as.data.frame(a3)
df3$b3 <- b3
c3 <- cov(df3)
names(df1) <- c("x","y")
names(df2) <- c("x","y")
names(df3) <- c("x","y")


g <- function(p,m,c,x,y){
  r = log(p)
  r = r - 0.5 * log(det(c))
  r = r - 0.5 * t(as.matrix(c(x,y))-m) %*% solve(c) %*% (as.matrix(c(x,y))-m)
  r
}

g(p1,m1,c1,5,9)
g(p2,m2,c2,5,9)
g(p3,m3,c3,5,9)
g(p1,m1,c1,9,8)
g(p2,m2,c2,9,8)
g(p3,m3,c3,9,8)
g(p1,m1,c1,15,9)
g(p2,m2,c2,15,9)
g(p3,m3,c3,15,9)

d <- function(m,x,y){
  g = 2* t(as.matrix(m)) %*% as.matrix(c(x,y)) - t(as.matrix(m)) %*% as.matrix(m)
  g
}

d(m1,5,9)
d(m2,5,9)
d(m3,5,9)

d(m1,9,8)
d(m2,9,8)
d(m3,9,8)

d(m1,15,9)
d(m2,15,9)
d(m3,15,9)
