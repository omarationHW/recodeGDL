<template>
  <div class="consulta-reg-page">
    <h1>Consulta por Registro Requerido</h1>
    <div class="consulta-form" v-if="!showDetalle">
      <label for="tipo">Aplicación:</label>
      <select v-model="form.tipo" id="tipo" @change="onTipoChange">
        <option value="0">Mercados</option>
        <option value="1">Aseo</option>
        <option value="2">Estacionamientos Públicos</option>
        <option value="3">Estacionamientos Exclusivos</option>
        <option value="4">Estacionómetros</option>
        <option value="5">Cementerios</option>
      </select>
      <div v-if="form.tipo == 0">
        <label>Oficina:</label>
        <input v-model="form.oficina" type="number" min="1" max="9" />
        <label>Mercado:</label>
        <input v-model="form.num_mercado" type="number" min="1" />
        <label>Sección:</label>
        <input v-model="form.seccion" type="text" maxlength="2" />
        <label>Local:</label>
        <input v-model="form.local" type="number" min="1" />
        <label>Letra:</label>
        <input v-model="form.letra_local" type="text" maxlength="1" />
        <label>Bloque:</label>
        <input v-model="form.bloque" type="text" maxlength="1" />
      </div>
      <div v-if="form.tipo == 1">
        <label>Num. Contrato:</label>
        <input v-model="form.contrato" type="number" min="1" />
        <label>Tipo:</label>
        <input v-model="form.tipo_aseo" type="text" maxlength="1" />
      </div>
      <div v-if="form.tipo == 2">
        <label>Num. Est. Público:</label>
        <input v-model="form.numesta" type="number" min="1" />
      </div>
      <div v-if="form.tipo == 3">
        <label>Num. Exclusivo:</label>
        <input v-model="form.no_exclusivo" type="number" min="1" />
      </div>
      <div v-if="form.tipo == 4">
        <label>Placa:</label>
        <input v-model="form.placa" type="text" maxlength="10" />
      </div>
      <div v-if="form.tipo == 5">
        <label>Folio Cementerio:</label>
        <input v-model="form.folio" type="number" min="1" />
      </div>
      <button @click="buscar">Buscar</button>
      <button @click="resetForm">Limpiar</button>
      <div v-if="error" class="error">{{ error }}</div>
    </div>
    <div v-if="showDetalle">
      <h2>Datos Generales</h2>
      <pre>{{ registro }}</pre>
      <h3>Detalle de Requerimientos</h3>
      <table class="detalle-table">
        <thead>
          <tr>
            <th v-for="col in detalleColumns" :key="col">{{ col }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in detalle" :key="row.id_control">
            <td v-for="col in detalleColumns" :key="col">{{ row[col] }}</td>
          </tr>
        </tbody>
      </table>
      <button @click="otroRegistro">Otro Registro</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsultaRegPage',
  data() {
    return {
      form: {
        tipo: 0,
        oficina: 1,
        num_mercado: '',
        seccion: '',
        local: '',
        letra_local: '',
        bloque: '',
        contrato: '',
        tipo_aseo: '',
        numesta: '',
        no_exclusivo: '',
        placa: '',
        folio: ''
      },
      registro: null,
      detalle: [],
      detalleColumns: [],
      showDetalle: false,
      error: ''
    };
  },
  methods: {
    onTipoChange() {
      // Limpiar campos al cambiar tipo
      this.form = {
        tipo: this.form.tipo,
        oficina: 1,
        num_mercado: '',
        seccion: '',
        local: '',
        letra_local: '',
        bloque: '',
        contrato: '',
        tipo_aseo: '',
        numesta: '',
        no_exclusivo: '',
        placa: '',
        folio: ''
      };
      this.error = '';
    },
    async buscar() {
      this.error = '';
      this.registro = null;
      this.detalle = [];
      this.showDetalle = false;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'buscar',
              params: this.form
            }
          })
        });
        const data = await res.json();
        if (!data.eResponse.success) {
          this.error = data.eResponse.message;
          return;
        }
        this.registro = data.eResponse.registro;
        this.detalle = data.eResponse.detalle;
        this.detalleColumns = this.detalle.length > 0 ? Object.keys(this.detalle[0]) : [];
        this.showDetalle = true;
      } catch (e) {
        this.error = 'Error de comunicación con el servidor.';
      }
    },
    resetForm() {
      this.form = {
        tipo: 0,
        oficina: 1,
        num_mercado: '',
        seccion: '',
        local: '',
        letra_local: '',
        bloque: '',
        contrato: '',
        tipo_aseo: '',
        numesta: '',
        no_exclusivo: '',
        placa: '',
        folio: ''
      };
      this.error = '';
      this.showDetalle = false;
    },
    async otroRegistro() {
      this.resetForm();
    }
  }
};
</script>

<style scoped>
.consulta-reg-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.consulta-form label {
  display: inline-block;
  width: 120px;
  margin-top: 0.5rem;
}
.consulta-form input, .consulta-form select {
  margin-bottom: 0.5rem;
  margin-right: 1rem;
}
.detalle-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.detalle-table th, .detalle-table td {
  border: 1px solid #ccc;
  padding: 0.3rem 0.5rem;
}
.error {
  color: red;
  margin-top: 1rem;
}
</style>
