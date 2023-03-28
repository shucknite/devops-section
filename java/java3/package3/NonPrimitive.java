
// non primitivedatatypes

class NonPrimitive {
    public static void main(String[] args) {
        String str = "test";
        System.out.println("String is: "+ str);

        String strl = new String("test");
        System.out.println("Another String: "+ strl);

        int arr[];
        arr = new int[2];
        arr[0] = 1;
        arr[1] = 2;

        System.out.println("int[]: "+ arr);
        System.out.println("int[]: "+ arr[0]);

    }

}