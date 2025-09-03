/*
EXECUTE sp_configure 'external rest endpoint enabled', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO
*/

DECLARE @ret AS INT, @response AS NVARCHAR (MAX);
EXECUTE
    @ret = sp_invoke_external_rest_endpoint
    @url = N'https://api.hnb.hr/tecajn-eur/v3',
    @method = 'GET',
    @response = @response OUTPUT;

SELECT @ret AS ReturnCode,
       @response AS Response;

SELECT 
    broj_tecajnice
     , datum_primjene
     , drzava
     , drzava_iso
     , kupovni_tecaj
     , prodajni_tecaj
     , srednji_tecaj
     , sifra_valute
     , valuta 
FROM OPENJSON(@response, '$.result') WITH (
     broj_tecajnice INT '$.broj_tecajnice'
     , datum_primjene DATE '$.datum_primjene'
     , drzava NVARCHAR(256) '$.drzava'
     , drzava_iso VARCHAR(3) '$.drzava_iso'
     , kupovni_tecaj VARCHAR(256) '$.kupovni_tecaj'
     , prodajni_tecaj VARCHAR(256) '$.prodajni_tecaj'
     , srednji_tecaj VARCHAR(256) '$.srednji_tecaj'
     , sifra_valute VARCHAR(3) '$.sifra_valute'
     , valuta VARCHAR(3) '$.valuta'
)
GO

