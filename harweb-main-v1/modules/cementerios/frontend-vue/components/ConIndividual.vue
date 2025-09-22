<template>
  <div class="con-individual">
    <h1>Consulta Individual por R.C.M</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Consulta Individual</span>
    </div>
    <form @submit.prevent="buscar">
      <div class="form-row">
        <label for="folio">Folio:</label>
        <input v-model="folio" id="folio" type="number" required />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="datos">
      <h2>Datos Generales</h2>
      <table class="datos-table">
        <tr><th>Cementerio</th><td>{{ datos.cementerio }}</td></tr>
        <tr><th>Folio</th><td>{{ datos.control_rcm }}</td></tr>
        <tr><th>Tipo</th><td>{{ tipoTexto(datos.tipo) }}</td></tr>
        <tr><th>Clase</th><td>{{ datos.clase }} ({{ datos.clase_alfa }})</td></tr>
        <tr><th>Sección</th><td>{{ datos.seccion }} ({{ datos.seccion_alfa }})</td></tr>
        <tr><th>Línea</th><td>{{ datos.linea }} ({{ datos.linea_alfa }})</td></tr>
        <tr><th>Fosa</th><td>{{ datos.fosa }} ({{ datos.fosa_alfa }})</td></tr>
        <tr><th>Nombre</th><td>{{ datos.nombre }}</td></tr>
        <tr><th>Domicilio</th><td>{{ datos.domicilio }}</td></tr>
        <tr><th>Exterior</th><td>{{ datos.exterior }}</td></tr>
        <tr><th>Interior</th><td>{{ datos.interior }}</td></tr>
        <tr><th>Colonia</th><td>{{ datos.colonia }}</td></tr>
        <tr><th>Observaciones</th><td>{{ datos.observaciones }}</td></tr>
        <tr><th>Ult. Año Pago</th><td>{{ datos.axo_pagado }}</td></tr>
        <tr><th>Metros</th><td>{{ datos.metros }}</td></tr>
        <tr><th>Fecha Mov.</th><td>{{ datos.fecha_mov }}</td></tr>
      </table>
      <div class="nav-links">
        <router-link :to="`/con-individual/pagos/${folio}`">Pagos</router-link>
        <router-link :to="`/con-individual/adeudos/${folio}`">Adeudos</router-link>
        <router-link :to="`/con-individual/descuentos/${folio}`">Descuentos</router-link>
        <router-link :to="`/con-individual/historico/${folio}`">Histórico</router-link>
        <router-link :to="`/con-individual/totales-cajero/${folio}`">Totales Cajero</router-link>
        <router-link :to="`/con-individual/persona-paga/${folio}`">Persona Paga</router-link>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConIndividual',
  data() {
    return {
      folio: '',
      datos: null,
      loading: false,
      error: ''
    };
  },
  methods: {
    tipoTexto(tipo) {
      switch (tipo) {
        case 'F': return 'FOSA';
        case 'U': return 'URNA';
        case 'G': return 'GAVETA';
        default: return tipo;
      }
    },
    async buscar() {
      this.loading = true;
      this.error = '';
      this.datos = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              procedure: 'sp_get_datosrcm',
              params: { fol: this.folio }
            }
          })
        });
        const json = await res.json();
        if (json.eResponse && json.eResponse.length > 0) {
          this.datos = json.eResponse[0];
        } else {
          this.error = 'No se encontraron datos para el folio.';
        }
      } catch (e) {
        this.error = 'Error al consultar: ' + e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.con-individual {
  max-width: 800px;
  margin: 0 auto;
  padding: 2em;
  background: #f9f9f9;
  border-radius: 8px;
}
.breadcrumb {
  margin-bottom: 1em;
  color: #888;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1em;
  margin-bottom: 1em;
}
.datos-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1em;
}
.datos-table th {
  text-align: left;
  background: #eee;
  padding: 0.5em;
}
.datos-table td {
  padding: 0.5em;
  border-bottom: 1px solid #ddd;
}
.nav-links {
  margin-top: 1em;
  display: flex;
  gap: 1em;
}
.loading { color: #007bff; }
.error { color: #c00; }
</style>
