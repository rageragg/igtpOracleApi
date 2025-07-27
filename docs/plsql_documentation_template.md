# Documentación de Código PL/SQL

Este documento sirve como guía y plantilla para documentar el código PL/SQL de la base de datos Oracle.

## 1. Información General

*   **Nombre del Objeto:** `[Nombre del Paquete/Procedimiento/Función]`
*   **Tipo de Objeto:** `[Paquete/Procedimiento/Función/Trigger]`
*   **Autor:** `[Nombre del Autor]`
*   **Fecha de Creación:** `[Fecha]`
*   **Versión:** `[Versión del Objeto]`
*   **Descripción:** Breve descripción del propósito y la funcionalidad del objeto.

## 2. Listado de Objetos

### 2.1. Paquetes

#### 2.1.1. `NOMBRE_PAQUETE_1`

*   **Descripción:** Descripción del propósito del paquete.

##### Procedimientos/Funciones Públicas

*   **`NOMBRE_PROCEDIMIENTO_1(parámetros)`:** Descripción del procedimiento.
*   **`NOMBRE_FUNCION_1(parámetros) RETURN tipo_dato`:** Descripción de la función.

##### Procedimientos/Funciones Privadas

*   **`NOMBRE_PROCEDIMIENTO_PRIVADO_1(parámetros)`:** Descripción del procedimiento.
*   **`NOMBRE_FUNCION_PRIVADA_1(parámetros) RETURN tipo_dato`:** Descripción de la función.

##### Tipos de Datos

*   **`TIPO_DATO_1`:** Descripción del tipo de dato.
*   **`TIPO_DATO_2`:** Descripción del tipo de dato.

##### Excepciones

*   **`EXCEPCION_1`:** Descripción de la excepción.

### 2.2. Procedimientos

#### 2.2.1. `NOMBRE_PROCEDIMIENTO`

*   **Descripción:** Descripción del propósito del procedimiento.

##### Parámetros

| Nombre | Tipo de Dato | IN/OUT | Descripción |
| :--- | :--- | :--- | :--- |
| `p_parametro_1` | `VARCHAR2` | IN | Descripción del parámetro 1. |
| `p_parametro_2` | `NUMBER` | OUT | Descripción del parámetro 2. |

##### Excepciones

*   **`NO_DATA_FOUND`:** Se lanza cuando no se encuentra un registro específico.
*   **`OTHERS`:** Manejo de excepciones no controladas.

##### Ejemplo de Uso

```sql
DECLARE
  v_parametro_2 NUMBER;
BEGIN
  NOMBRE_PROCEDIMIENTO(
    p_parametro_1 => 'valor',
    p_parametro_2 => v_parametro_2
  );
  DBMS_OUTPUT.PUT_LINE('Valor de salida: ' || v_parametro_2);
END;
/
```

### 2.3. Funciones

#### 2.3.1. `NOMBRE_FUNCION`

*   **Descripción:** Descripción del propósito de la función.

##### Parámetros

| Nombre | Tipo de Dato | IN/OUT | Descripción |
| :--- | :--- | :--- | :--- |
| `p_parametro_1` | `VARCHAR2` | IN | Descripción del parámetro 1. |
| `p_parametro_2` | `NUMBER` | IN | Descripción del parámetro 2. |

##### Valor de Retorno

*   **Tipo de Dato:** `VARCHAR2`
*   **Descripción:** Descripción del valor de retorno.

##### Excepciones

*   **`NO_DATA_FOUND`:** Se lanza cuando no se encuentra un registro específico.
*   **`OTHERS`:** Manejo de excepciones no controladas.

##### Ejemplo de Uso

```sql
DECLARE
  v_resultado VARCHAR2(100);
BEGIN
  v_resultado := NOMBRE_FUNCION(
    p_parametro_1 => 'valor',
    p_parametro_2 => 123
  );
  DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_resultado);
END;
/
```

### 2.4. Triggers

#### 2.4.1. `NOMBRE_TRIGGER`

*   **Descripción:** Descripción del propósito del trigger.
*   **Tabla:** `NOMBRE_TABLA`
*   **Tipo:** `[BEFORE/AFTER] [INSERT/UPDATE/DELETE]`
*   **Nivel:** `[FOR EACH ROW/STATEMENT]`

##### Lógica del Trigger

Descripción de la lógica que se ejecuta cuando se dispara el trigger.

##### Ejemplo

```sql
-- Ejemplo de cómo se dispara el trigger
UPDATE NOMBRE_TABLA
SET columna = 'nuevo_valor'
WHERE id = 1;
```

## 3. Historial de Cambios

| Versión | Fecha | Autor | Descripción del Cambio |
| :--- | :--- | :--- | :--- |
| 1.0 | 2023-01-01 | Nombre del Autor | Creación inicial del objeto. |
| 1.1 | 2023-01-15 | Nombre del Autor | Se agregó el manejo de la excepción `NO_DATA_FOUND`. |
