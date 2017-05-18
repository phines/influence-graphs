function myarrow(from,to,width,color)

x = [from(1) to(1)];
y = [from(2) to(2)];

line(x,y,'Color',color,'LineWidth',width);
plot(to(1),to(2),'d','MarkerFaceColor',color,'MarkerEdgeColor','k','MarkerSize',width*2);
