from graphics import *
import pandas as pd
import matplotlib.pyplot as plt

data = None
filtered_data = None
default_export_path = "graph.png"

def display_user_guide():
    win = GraphWin("User Guide", 500, 300)
    win.setBackground("light gray")

    guide_text = (
        "Welcome to the Data Analysis App!\n\n"
        "Steps to use the app:\n"
        "1. Import a CSV file.\n"
        "2. Choose the feature you want to analyze.\n"
        "3. Apply filters to narrow down your data.\n"
        "Order status: COMPLETE, PENDING, ON_HOLD,\n"
        "CANCELLED, PENDING_PAYMENT,PROCESSING, CLOSED, SUSPECTED_FRAUD\n"
        "Time range (from 2016 - 2018)\n"
        "US State: by abbreviations\n"
        "4. Select the type of graph to visualize your data.\n"
        "5. Export the graph if needed.\n\n"
        "Click the 'Continue' button to get started!"
    )
    Text(Point(250, 100), guide_text).draw(win)

    continue_button = Rectangle(Point(200, 200), Point(300, 240))
    continue_button.setFill("cyan")
    continue_button.draw(win)
    Text(Point(250, 220), "Continue").draw(win)

    while True:
        click = win.getMouse()
        if 200 <= click.x <= 300 and 200 <= click.y <= 240:
            win.close()
            break

def import_csv():
    global data
    win = GraphWin("CSV Import", 400, 200)
    win.setBackground("light gray")
    Text(Point(200, 50), "Enter the name of the CSV file:").draw(win)

    file_input = Entry(Point(200, 100), 20)
    file_input.draw(win)

    submit_button = Rectangle(Point(150, 130), Point(250, 160))
    submit_button.setFill("cyan")
    submit_button.draw(win)
    Text(Point(200, 145), "Submit").draw(win)

    while True:
        click = win.getMouse()
        if 150 <= click.x <= 250 and 130 <= click.y <= 160:
            file_name = file_input.getText()
            try:
                data = pd.read_csv(file_name)
                win.close()
                break
            except Exception as e:
                # Display an error message
                error_message = Text(Point(200, 180), f"Error: {e}")
                error_message.setFill("red")
                error_message.draw(win)

def draw_feature_selection():
    win = GraphWin("Feature Selection", 400, 400)
    win.setBackground("light gray")

    Text(Point(200, 50), "Choose a feature to analyze:").draw(win)

    options = [
        "1. Shipment Efficiency Analysis",
        "2. Sales by State",
        "3. Sales by Product Category",
        "4. Orders by Region",
    ]
    y_pos = 100
    for option in options:
        Text(Point(200, y_pos), option).draw(win)
        y_pos += 30
    feature_input = Entry(Point(200, y_pos), 10)
    feature_input.draw(win)

    submit_button = Rectangle(Point(150, y_pos + 30), Point(250, y_pos + 60))
    submit_button.setFill("cyan")
    submit_button.draw(win)
    Text(Point(200, y_pos + 45), "Submit").draw(win)

    while True:
        click = win.getMouse()
        if 150 <= click.x <= 250 and y_pos + 30 <= click.y <= y_pos + 60:
            choice = feature_input.getText()
            win.close()
            return choice

def apply_filters():
    global data, filtered_data
    filtered_data = data.copy()

    win = GraphWin("Filters", 400, 450)
    win.setBackground("light gray")

    Text(Point(200, 30), "Order Status (e.g., COMPLETE, ALL):").draw(win)
    order_status_input = Entry(Point(200, 60), 20)
    order_status_input.draw(win)

    Text(Point(200, 90), "Year or Date Range (e.g., 2016, 2016-2018):").draw(win)
    date_input = Entry(Point(200, 120), 20)
    date_input.draw(win)

    Text(Point(200, 150), "State Abbreviations (comma-separated or ALL):").draw(win)
    state_input = Entry(Point(200, 180), 20)
    state_input.draw(win)

    Text(Point(200, 210), "Order Region (comma-separated or ALL):").draw(win)
    region_input = Entry(Point(200, 240), 20)
    region_input.draw(win)

    submit_button = Rectangle(Point(150, 300), Point(250, 330))
    submit_button.setFill("cyan")
    submit_button.draw(win)
    Text(Point(200, 315), "Submit").draw(win)

    while True:
        click = win.getMouse()
        if 150 <= click.x <= 250 and 300 <= click.y <= 330:
            order_status = order_status_input.getText().upper()
            date_filter = date_input.getText()
            state_filter = state_input.getText().upper()
            region_filter = region_input.getText().upper()

            if order_status != "ALL":
                statuses = order_status.split(",")
                filtered_data = filtered_data[filtered_data['Order Status'].isin(statuses)]

            filtered_data['Year'] = pd.to_datetime(filtered_data['order date (DateOrders)']).dt.year
            if "-" in date_filter:
                start_year, end_year = map(int, date_filter.split("-"))
                filtered_data = filtered_data[(filtered_data['Year'] >= start_year) & (filtered_data['Year'] <= end_year)]
            elif date_filter.isdigit():
                year = int(date_filter)
                filtered_data = filtered_data[filtered_data['Year'] == year]

            if state_filter != "ALL":
                states = state_filter.split(",")
                filtered_data = filtered_data[filtered_data['Customer State'].isin(states)]

            if region_filter != "ALL":
                regions = region_filter.split(",")
                filtered_data = filtered_data[filtered_data['Order Region'].isin(regions)]

            win.close()
            break

def select_graph_type():
    win = GraphWin("Graph Type Selection", 400, 200)
    win.setBackground("light gray")
    Text(Point(200, 50), "Choose a graph type:").draw(win)

    options = ["Bar", "Pie", "Line"]
    y_pos = 100
    buttons = []
    for option in options:
        button = Rectangle(Point(150, y_pos - 10), Point(250, y_pos + 20))
        button.setFill("cyan")
        button.draw(win)
        Text(Point(200, y_pos + 5), option).draw(win)
        buttons.append((button, option))
        y_pos += 40

    while True:
        click = win.getMouse()
        for button, graph_type in buttons:
            p1, p2 = button.getP1(), button.getP2()
            if p1.x <= click.x <= p2.x and p1.y <= click.y <= p2.y:
                win.close()
                return graph_type

def draw_graph(graph_title, x_data, y_data, x_label, y_label, graph_type):
    global default_export_path

    if graph_type == "Bar":
        plt.bar(x_data, y_data)
    elif graph_type == "Pie":
        plt.pie(y_data, labels=x_data, autopct="%1.1f%%")
    elif graph_type == "Line":
        plt.plot(x_data, y_data, marker="o")

    plt.title(graph_title)
    plt.xlabel(x_label)
    plt.ylabel(y_label if graph_type != "Pie" else "")
    if graph_type != "Pie":
        plt.xticks(rotation=45, ha="right")
    plt.savefig(default_export_path)
    plt.close()

    win = GraphWin("Graph Display", 800, 700)
    graph_image = Image(Point(400, 300), default_export_path)
    graph_image.draw(win)

    export_button = Rectangle(Point(350, 600), Point(450, 650))
    export_button.setFill("cyan")
    export_button.draw(win)
    Text(Point(400, 625), "Export").draw(win)

    file_name_input = Entry(Point(400, 570), 20)
    file_name_input.draw(win)
    Text(Point(400, 550), "Export File Name (e.g., my_graph.png):").draw(win)

    while True:
        click = win.getMouse()
        if 350 <= click.x <= 450 and 600 <= click.y <= 650:
            export_file_name = file_name_input.getText()
            if export_file_name:

                if graph_type == "Bar":
                    plt.bar(x_data, y_data)
                elif graph_type == "Pie":
                    plt.pie(y_data, labels=x_data, autopct="%1.1f%%")
                elif graph_type == "Line":
                    plt.plot(x_data, y_data, marker="o")
                plt.title(graph_title)
                plt.xlabel(x_label)
                plt.ylabel(y_label if graph_type != "Pie" else "")
                if graph_type != "Pie":
                    plt.xticks(rotation=45, ha="right")
                plt.savefig(export_file_name)
                plt.close()
            win.close()
            break

def shipment_efficiency_analysis():
    global filtered_data
    apply_filters()
    win = GraphWin("Shipping Mode", 400, 200)
    win.setBackground("light gray")
    Text(Point(200, 50), "Enter Shipping Mode (e.g., First Class):").draw(win)

    mode_input = Entry(Point(200, 100), 20)
    mode_input.draw(win)

    submit_button = Rectangle(Point(150, 130), Point(250, 160))
    submit_button.setFill("cyan")
    submit_button.draw(win)
    Text(Point(200, 145), "Submit").draw(win)

    while True:
        click = win.getMouse()
        if 150 <= click.x <= 250 and 130 <= click.y <= 160:
            shipping_mode = mode_input.getText()
            win.close()

            filtered_data = filtered_data[filtered_data['Shipping Mode'] == shipping_mode]
            shipping_days = filtered_data['Days for shipping (real)'].value_counts().sort_index()


            graph_type = select_graph_type()


            draw_graph(
                f"Shipment Efficiency ({shipping_mode})",
                shipping_days.index,
                shipping_days.values,
                "Days for Shipping",
                "Number of Orders",
                graph_type,
            )
            break


def sales_by_state():
    global filtered_data
    apply_filters()
    sales_by_state = filtered_data.groupby("Customer State")["Order Item Total"].sum()
    graph_type = select_graph_type()

    draw_graph(
        "Sales by State",
        sales_by_state.index,
        sales_by_state.values,
        "State",
        "Total Sales",
        graph_type,
    )

def sales_by_category():
    global filtered_data
    apply_filters()
    sales_by_category = filtered_data.groupby("Category Name")["Order Item Total"].sum()
    graph_type = select_graph_type()

    draw_graph(
        "Sales by Product Category",
        sales_by_category.index,
        sales_by_category.values,
        "Category",
        "Total Sales",
        graph_type,
    )

def orders_by_region():
    global filtered_data
    apply_filters()
    orders_by_region = filtered_data['Order Country'].value_counts()
    graph_type = select_graph_type()

    draw_graph(
        "Orders by Region",
        orders_by_region.index,
        orders_by_region.values,
        "Region",
        "Number of Orders",
        graph_type,
    )
def main():
    global data
    display_user_guide()
    import_csv()
    choice = draw_feature_selection()

    if choice == "1":
        shipment_efficiency_analysis()
    elif choice == "2":
        sales_by_state()
    elif choice == "3":
        sales_by_category()
    elif choice == "4":
        orders_by_region()
    else:
        print("Invalid feature selected.")

if __name__ == "__main__":
    main()
