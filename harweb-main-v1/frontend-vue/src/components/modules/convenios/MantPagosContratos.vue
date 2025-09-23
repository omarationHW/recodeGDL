<template>
  <div class="mant-pagos-contratos-page">
    <h1>Mantenimiento de Pagos de Contratos</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Pagos Contratos</li>
      </ol>
    </nav>
    <form @submit.prevent="onBuscarPago">
      <fieldset>
        <legend>Buscar Pago</legend>
        <div class="form-row">
          <label>Fecha de Pago:
            <input type="date" v-model="form.fecha_pago" required />
          </label>
          <label>Oficina:
            <select v-model="form.oficina_pago" required>
              <option v-for="of in recaudadoras" :key="of.id" :value="of.id">{{ of.nombre }}</option>
            </select>
          </label>
          <label>Caja:
            <select v-model="form.caja_pago" required>
              <option v-for="cj in cajas" :key="cj.id" :value="cj.id">{{ cj.nombre }}</option>
            </select>
          </label>
          <label>Operación:
            <input type="number" v-model="form.operacion_pago" required min="1" />
          </label>
          <button type="submit">Buscar</button>
        </div>
      </fieldset>
    </form>
    <form @submit.prevent="onAgregarPago" v-if="showAgregar">
      <fieldset>
        <legend>Agregar/Modificar Pago</legend>
        <div class="form-row">
          <label>Colonia:
            <input type="number" v-model="form.colonia" required min="1" />
          </label>
          <label>Calle:
            <input type="number" v-model="form.calle" required min="1" />
          </label>
          <label>Folio:
            <input type="number" v-model="form.folio" required min="1" />
          </label>
          <label>Parcialidad Pagada:
            <input type="number" v-model="form.pago_parcial" required min="1" />
          </label>
          <label>Total Parcialidades:
            <input type="number" v-model="form.total_parciales" required min="1" />
          </label>
          <label>Importe:
            <input type="number" v-model="form.importe" required min="1" step="0.01" />
          </label>
          <label>Cve. Descuento:
            <input type="number" v-model="form.cve_descuento" min="0" />
          </label>
          <label>Cve. Devolución:
            <input type="number" v-model="form.cve_bonificacion" min="0" />
          </label>
        </div>
        <div class="form-row">
          <button type="button" @click="onAgregarPago">Agregar</button>
          <button type="button" @click="onModificarPago">Modificar</button>
          <button type="button" @click="onBorrarPago">Borrar</button>
          <button type="button" @click="resetForm">Cancelar</button>
        </div>
      </fieldset>
    </form>
    <div v-if="responseMessage" :class="{'success': responseStatus==='success', 'error': responseStatus==='error'}">
      {{ responseMessage }}
    </div>
    <div v-if="pagoEncontrado">
      <h3>Pago Encontrado</h3>
      <pre>{{ pagoEncontrado }}</pre>
    </div>
    <div v-if="contratoEncontrado">
      <h3>Contrato Encontrado</h3>
      <pre>{{ contratoEncontrado }}</pre>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MantPagosContratosPage',
  data() {
    return {
      form: {
        fecha_pago: '',
        oficina_pago: '',
        caja_pago: '',
        operacion_pago: '',
        colonia: '',
        calle: '',
        folio: '',
        pago_parcial: '',
        total_parciales: '',
        importe: '',
        cve_descuento: '',
        cve_bonificacion: '',
        id_usuario: 1 // Simulación, debe venir del login
      },
      recaudadoras: [],
      cajas: [],
      showAgregar: false,
      pagoEncontrado: null,
      contratoEncontrado: null,
      responseMessage: '',
      responseStatus: ''
    };
  },
  created() {
    this.fetchRecaudadoras();
  },
  watch: {
    'form.oficina_pago'(val) {
      if (val) this.fetchCajas(val);
    }
  },
  methods: {
    async fetchRecaudadoras() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'listar_recaudadoras' })
      });
      const json = await res.json();
      this.recaudadoras = json.data.map(r => ({ id: r.id_rec, nombre: r.nombre }));
    },
    async fetchCajas(oficinaId) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'listar_cajas', data: { oficina_pago: oficinaId } })
      });
      const json = await res.json();
      this.cajas = json.data.map(c => ({ id: c.caja, nombre: c.caja }));
    },
    async onBuscarPago() {
      this.responseMessage = '';
      this.responseStatus = '';
      this.pagoEncontrado = null;
      this.contratoEncontrado = null;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'buscar_pago',
          data: {
            fecha_pago: this.form.fecha_pago,
            oficina_pago: this.form.oficina_pago,
            caja_pago: this.form.caja_pago,
            operacion_pago: this.form.operacion_pago
          }
        })
      });
      const json = await res.json();
      if (json.status === 'success' && json.data.length > 0) {
        this.pagoEncontrado = json.data[0];
        this.showAgregar = true;
        // Cargar datos en el formulario para modificar/borrar
        Object.assign(this.form, this.pagoEncontrado);
        this.responseMessage = 'Pago encontrado';
        this.responseStatus = 'success';
      } else {
        this.responseMessage = 'No se encontró el pago. Puede agregar uno nuevo.';
        this.responseStatus = 'error';
        this.showAgregar = true;
      }
    },
    async onAgregarPago() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'agregar_pago',
          data: this.form
        })
      });
      const json = await res.json();
      this.responseMessage = json.message;
      this.responseStatus = json.status;
      if (json.status === 'success') {
        this.resetForm();
      }
    },
    async onModificarPago() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'modificar_pago',
          data: this.form
        })
      });
      const json = await res.json();
      this.responseMessage = json.message;
      this.responseStatus = json.status;
      if (json.status === 'success') {
        this.resetForm();
      }
    },
    async onBorrarPago() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'borrar_pago',
          data: {
            fecha_pago: this.form.fecha_pago,
            oficina_pago: this.form.oficina_pago,
            caja_pago: this.form.caja_pago,
            operacion_pago: this.form.operacion_pago
          }
        })
      });
      const json = await res.json();
      this.responseMessage = json.message;
      this.responseStatus = json.status;
      if (json.status === 'success') {
        this.resetForm();
      }
    },
    resetForm() {
      this.form = {
        fecha_pago: '',
        oficina_pago: '',
        caja_pago: '',
        operacion_pago: '',
        colonia: '',
        calle: '',
        folio: '',
        pago_parcial: '',
        total_parciales: '',
        importe: '',
        cve_descuento: '',
        cve_bonificacion: '',
        id_usuario: 1
      };
      this.showAgregar = false;
      this.pagoEncontrado = null;
      this.contratoEncontrado = null;
    }
  }
};
</script>

<style scoped>
.mant-pagos-contratos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  padding: 0.5rem 1rem;
  margin-bottom: 1rem;
}
fieldset {
  border: 1px solid #ccc;
  margin-bottom: 1rem;
  padding: 1rem;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 1rem;
}
label {
  flex: 1 1 200px;
  display: flex;
  flex-direction: column;
}
.success {
  color: green;
}
.error {
  color: red;
}
</style>
