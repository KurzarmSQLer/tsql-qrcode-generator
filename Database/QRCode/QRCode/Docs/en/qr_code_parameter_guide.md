
Important: A QR Code's capacity is not determined by its version alone. Capacity depends on the combination of version, error correction level, encoding mode and payload content.



# Version Selection Strategy

Two different approaches can be used when selecting the QR Code version.

## Automatic Version Selection

The recommended approach is to let the generator determine the smallest possible version that can hold the payload.

Example:

```sql
EXEC [QR].[pCreateQrCode]
     @Text = N'https://www.contoso.com';
```

Benefits:

- Smallest possible QR Code
- Better scanning performance
- Reduced print area requirements

## Fixed Version Selection

A fixed version should only be used when the QR Code must fit into an existing template or layout.

Example:

```sql
EXEC [QR].[pCreateQrCode]
     @Text                 = N'https://www.contoso.com',
     @VersionNumber        = 10,
     @ErrorCorrectionLevel = 'M';
```

If the payload exceeds the available capacity of the specified version, QR Code generation will fail.


# Capacity Planning

When planning a QR Code solution, always start with the expected payload.

Example:

```text
Customer Number
123456789
```

requires significantly less capacity than

```json
{
  "CustomerId": 123456789,
  "FirstName": "John",
  "LastName": "Doe",
  "Address": "..."
}
```

Even though both represent similar business information.

The required QR Code version is primarily driven by:

1. Payload size
2. Encoding mode
3. Error correction level

The physical QR Code version should be considered the result of these requirements rather than the starting point.


# Frequently Asked Questions

## Does a larger version always improve scan reliability?

No.

A larger QR Code only increases available capacity.

Scan reliability is primarily influenced by:

- Error correction level
- Print quality
- Module size
- Scanner quality

## Should I always use Error Correction Level H?

No.

Higher error correction reduces usable payload capacity.

For most business applications, Level M provides an excellent balance between robustness and capacity.

## Can two QR Codes of the same version contain different amounts of data?

Yes.

The maximum capacity depends on:

- Encoding mode
- Error correction level

For example, a Version 15 QR Code can store significantly more numeric characters than UTF-8 text.

## What is the most space-efficient payload?

Pure numeric data.

Example:

```text
12345678901234567890
```

Numeric mode provides the highest storage density available in the QR Code standard.

## What is the least space-efficient payload?

UTF-8 data containing multi-byte characters such as:

```text
München 😊 漢字
```

These payloads require considerably more storage capacity than ASCII text.



# Which Settings Should I Use?

| Scenario | Recommended ECL | Recommended Version Strategy |
|-----------|-----------|-----------|
| Numeric Identifier | L | Automatic |
| Serial Number | M | Automatic |
| Website URL | M | Automatic |
| Business Document Reference | M | Automatic |
| JSON Payload | M or Q | Automatic |
| Printed Product Label | Q | Automatic |
| Industrial Asset Label | H | Automatic |
| Fixed Layout Template | M or Q | Fixed Version |
| Capacity Testing | L | Fixed Version 40 |

In most business applications the recommended starting point is:

```sql
EXEC [QR].[pCreateQrCode]
     @Text                 = @Payload,
     @ErrorCorrectionLevel = 'M';
```

This configuration usually provides the best balance between capacity, size and robustness.
