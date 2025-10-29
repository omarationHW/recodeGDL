<template>
  <div class="ubicodifica-page">
    <h1>Codificación de Ubicación</h1>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-else>
      <form @submit.prevent="onSubmit">
        <div class="form-group">
          <label for="cvecuenta">Clave de Cuenta</label>
          <input v-model="form.cvecuenta" id="cvecuenta" type="number" required @change="fetchData" />
        </div>
        <div v-if="datoscont">
          <h3>Datos del Contribuyente</h3>
          <p><strong>Nombre:</strong> {{ datoscont.ncompleto }}</p>
          <p><strong>Calle:</strong> {{ datoscont.calle }}</p>
          <p><strong>No. Exterior:</strong> {{ datoscont.noexterior }}</p>
          <p><strong>Interior:</strong> {{ datoscont.interior }}</p>
          <p><strong>Zona:</strong> {{ datoscont.recaud }}</p>
          <p><strong>Cuenta:</strong> {{ datoscont.cuenta }}</p>
        </div>
        <div v-if="codifica">
          <h3>Codificación Actual</h3>
          <p><strong>Fecha Alta:</strong> {{ codifica.fec_alta }}</p>
          <p><strong>Usuario Alta:</strong> {{ codifica.usuario_alta }}</p>
          <p><strong>Vigencia:</strong> {{ codifica.vigencia }}</p>
          <p><strong>Fecha Mov:</strong> {{ codifica.fec_mov }}</p>
          <p><strong>Usuario Mov:</strong> {{ codifica.usuario_mov }}</p>
          <p v-if="codifica.fec_baja"><strong>Fecha Baja:</strong> {{ codifica.fec_baja }}</p>
        </div>
        <div class="actions">
          <button v-if="!codifica" type="button" @click="altaUbicodifica">Dar de Alta</button>
          <button v-if="codifica && codifica.vigencia === 'C'" type="button" @click="actualizaUbicodifica">Reactivar</button>
          <button v-if="codifica && codifica.vigencia === 'V'" type="button" @click="cancelaUbicodifica">Cancelar</button>
        </div>
      </form>
      <hr />
      <h2>Listado de cuentas sin zona/subzona</h2>
      <form @submit.prevent="onListado">
        <div class="form-row">
          <label>Recaudadora</label>
          <input v-model="listadoForm.reca" type="number" required />
          <label>Cuenta Inicial</label>
          <input v-model="listadoForm.ctaini" type="number" required />
          <label>Cuenta Final</label>
          <input v-model="listadoForm.ctafin" type="number" required />
          <button type="submit">Buscar</button>
        </div>
      </form>
      <table v-if="listado.length">
        <thead>
          <tr>
            <th>Recaud</th>
            <th>URBRUS</th>
            <th>Cuenta</th>
            <th>Cve Catastral</th>
            <th>Calle</th>
            <th>No. Exterior</th>
            <th>Interior</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in listado" :key="row.cvecatnva">
            <td>{{ row.recaud }}</td>
            <td>{{ row.urbrus }}</td>
            <td>{{ row.cuenta }}</td>
            <td>{{ row.cvecatnva }}</td>
            <td>{{ row.calle }}</td>
            <td>{{ row.noexterior }}</td>
            <td>{{ row.interior }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'UbicodificaPage',
  data() {
    return {
      form: {
        cvecuenta: ''
      },
      datoscont: null,
      codifica: null,
      loading: false,
      listadoForm: {
        reca: '',
        ctaini: '',
        ctafin: ''
      },
      listado: []
    };
  },
  methods: {
    async fetchData() {
      if (!this.form.cvecuenta) return;
      this.loading = true;
      try {
        const res = await axios.post('/api/execute', {
          action: 'get_ubicodifica_data',
          params: { cvecuenta: this.form.cvecuenta }
        });
        this.datoscont = res.data.datoscont;
        this.codifica = res.data.codifica;
      } catch (e) {
        this.datoscont = null;
        this.codifica = null;
        this.$toast && this.$toast.error('No se encontró la cuenta');
      } finally {
        this.loading = false;
      }
    },
    async altaUbicodifica() {
      if (!this.form.cvecuenta) return;
      this.loading = true;
      try {
        const res = await axios.post('/api/execute', {
          action: 'alta_ubicodifica',
          params: { cvecuenta: this.form.cvecuenta }
        });
        if (res.data.success) {
          this.$toast && this.$toast.success('Alta exitosa');
          this.fetchData();
        } else {
          this.$toast && this.$toast.error(res.data.error || 'Error al dar de alta');
        }
      } finally {
        this.loading = false;
      }
    },
    async actualizaUbicodifica() {
      if (!this.form.cvecuenta) return;
      this.loading = true;
      try {
        const res = await axios.post('/api/execute', {
          action: 'actualiza_ubicodifica',
          params: { cvecuenta: this.form.cvecuenta }
        });
        if (res.data.success) {
          this.$toast && this.$toast.success('Actualización exitosa');
          this.fetchData();
        } else {
          this.$toast && this.$toast.error(res.data.error || 'Error al actualizar');
        }
      } finally {
        this.loading = false;
      }
    },
    async cancelaUbicodifica() {
      if (!this.form.cvecuenta) return;
      this.loading = true;
      try {
        const res = await axios.post('/api/execute', {
          action: 'cancela_ubicodifica',
          params: { cvecuenta: this.form.cvecuenta }
        });
        if (res.data.success) {
          this.$toast && this.$toast.success('Cancelación exitosa');
          this.fetchData();
        } else {
          this.$toast && this.$toast.error(res.data.error || 'Error al cancelar');
        }
      } finally {
        this.loading = false;
      }
    },
    async onListado() {
      this.loading = true;
      try {
        const res = await axios.post('/api/execute', {
          action: 'listado_ubicodifica',
          params: this.listadoForm
        });
        this.listado = res.data.listado || [];
      } catch (e) {
        this.listado = [];
        this.$toast && this.$toast.error('Error al buscar listado');
      } finally {
        this.loading = false;
      }
    },
    onSubmit() {
      // No submit, handled by buttons
    }
  }
};
</script>

<style scoped>
.ubicodifica-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-group, .form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-group label, .form-row label {
  min-width: 120px;
  margin-right: 0.5rem;
}
.form-group input, .form-row input {
  margin-right: 1rem;
}
.actions {
  margin-top: 1rem;
}
.loading {
  color: #888;
  font-size: 1.2em;
}
table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
th, td {
  border: 1px solid #ccc;
  padding: 0.5rem;
  text-align: left;
}
th {
  background: #f5f5f5;
}
</style>
