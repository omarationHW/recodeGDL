<template>
  <div class="titulosin-page">
    <h1>Impresión de Título de Propiedad Sin Referencias</h1>
    <form @submit.prevent="onSubmit">
      <div class="form-row">
        <label>Fecha de Pago:</label>
        <input type="date" v-model="form.fecha" required />
      </div>
      <div class="form-row">
        <label>Ofna:</label>
        <input type="number" v-model="form.ofna" min="1" max="5" required />
        <label>Caja:</label>
        <input type="text" v-model="form.caja" maxlength="1" required />
        <label>Operación:</label>
        <input type="number" v-model="form.operacion" required />
      </div>
      <div class="form-row">
        <label>Folio:</label>
        <input type="number" v-model="form.folio" required />
      </div>
      <div class="form-row">
        <button type="button" @click="buscarIngresos">Buscar Ingresos</button>
      </div>
      <div v-if="ingresos">
        <div class="form-row">
          <label>Título:</label>
          <input type="number" v-model="form.titulo" />
        </div>
        <div class="form-row">
          <label>Partida:</label>
          <input type="number" v-model="form.partida" />
        </div>
        <div class="form-row">
          <label>Teléfono:</label>
          <input type="text" v-model="form.telefono" maxlength="20" />
        </div>
        <div class="form-row">
          <button type="submit">Imprimir Título</button>
          <button type="button" @click="resetForm">Cancelar</button>
        </div>
      </div>
      <div v-if="error" class="error">{{ error }}</div>
      <div v-if="success" class="success">{{ success }}</div>
    </form>
    <div v-if="imprimirData">
      <h2>Vista Previa de Título</h2>
      <pre>{{ imprimirData }}</pre>
      <!-- Aquí se puede renderizar el PDF o datos de impresión -->
    </div>
  </div>
</template>

<script>
export default {
  name: 'TituloSinPage',
  data() {
    return {
      form: {
        fecha: '',
        ofna: 1,
        caja: '',
        operacion: '',
        folio: '',
        titulo: '',
        partida: '',
        telefono: ''
      },
      ingresos: null,
      error: '',
      success: '',
      imprimirData: null
    };
  },
  methods: {
    async buscarIngresos() {
      this.error = '';
      this.success = '';
      this.imprimirData = null;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getIngresos',
          payload: {
            fecha: this.form.fecha,
            ofna: this.form.ofna,
            caja: this.form.caja,
            operacion: this.form.operacion
          }
        });
        if (res.data.success && res.data.data) {
          this.ingresos = res.data.data;
          this.success = 'Ingreso encontrado.';
        } else {
          this.error = res.data.message || 'No se encontró el ingreso.';
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      }
    },
    async onSubmit() {
      this.error = '';
      this.success = '';
      this.imprimirData = null;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'printTituloSin',
          payload: {
            folio: this.form.folio,
            fecha: this.form.fecha,
            operacion: this.form.operacion,
            rec: this.form.ofna,
            telefono: this.form.telefono,
            partida: this.form.partida
          }
        });
        if (res.data.success && res.data.data) {
          this.imprimirData = res.data.data;
          this.success = 'Título listo para impresión.';
        } else {
          this.error = res.data.message || 'No se pudo imprimir el título.';
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      }
    },
    resetForm() {
      this.form = {
        fecha: '',
        ofna: 1,
        caja: '',
        operacion: '',
        folio: '',
        titulo: '',
        partida: '',
        telefono: ''
      };
      this.ingresos = null;
      this.error = '';
      this.success = '';
      this.imprimirData = null;
    }
  }
};
</script>

<style scoped>
.titulosin-page {
  max-width: 600px;
  margin: 0 auto;
  background: #fff;
  padding: 2em;
  border-radius: 8px;
  box-shadow: 0 2px 8px #ccc;
}
.form-row {
  margin-bottom: 1em;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 120px;
  font-weight: bold;
}
.form-row input {
  flex: 1;
  margin-right: 1em;
}
.error {
  color: #b00;
  margin-top: 1em;
}
.success {
  color: #080;
  margin-top: 1em;
}
</style>
