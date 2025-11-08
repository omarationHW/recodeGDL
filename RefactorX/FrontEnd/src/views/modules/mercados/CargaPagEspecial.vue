<template>
  <div class="carga-pag-especial">
    <h1>Carga de Pagos Especial (Años Anteriores sin Fecha de Ingreso)</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Carga Pagos Especial</li>
      </ol>
    </nav>
    <div class="row">
      <div class="col-md-6">
        <h3>Mercado</h3>
        <select v-model="selectedMercado" @change="onMercadoChange" class="form-control">
          <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m">{{ m.num_mercado_nvo }} - {{ m.descripcion }}</option>
        </select>
      </div>
      <div class="col-md-6">
        <h3>Datos del Pago</h3>
        <div class="form-row">
          <div class="form-group col-md-3">
            <label>Oficina</label>
            <input type="number" v-model="form.oficina_pago" class="form-control" />
          </div>
          <div class="form-group col-md-3">
            <label>Caja</label>
            <input type="text" v-model="form.caja_pago" class="form-control" maxlength="2" />
          </div>
          <div class="form-group col-md-3">
            <label>Operación</label>
            <input type="number" v-model="form.operacion_pago" class="form-control" />
          </div>
          <div class="form-group col-md-3">
            <label>Fecha Pago</label>
            <input type="date" v-model="form.fecha_pago" class="form-control" />
          </div>
        </div>
        <div class="form-group">
          <label>Local</label>
          <input type="number" v-model="form.local" class="form-control" />
        </div>
        <button class="btn btn-primary" @click="buscarAdeudos">Buscar Adeudos</button>
      </div>
    </div>
    <div v-if="adeudos.length > 0" class="mt-4">
      <h4>Adeudos del Local</h4>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Control</th>
            <th>Rec</th>
            <th>Merc</th>
            <th>Cat</th>
            <th>Secc</th>
            <th>Local</th>
            <th>Letra</th>
            <th>Bloque</th>
            <th>Año</th>
            <th>Mes</th>
            <th>Renta</th>
            <th>Partida</th>
            <th>Seleccionar</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(a, idx) in adeudos" :key="a.id_local + '-' + a.axo + '-' + a.periodo">
            <td>{{ a.id_local }}</td>
            <td>{{ a.oficina }}</td>
            <td>{{ a.num_mercado }}</td>
            <td>{{ a.categoria }}</td>
            <td>{{ a.seccion }}</td>
            <td>{{ a.local }}</td>
            <td>{{ a.letra_local }}</td>
            <td>{{ a.bloque }}</td>
            <td>{{ a.axo }}</td>
            <td>{{ a.periodo }}</td>
            <td><input type="number" v-model.number="a.importe" class="form-control form-control-sm" /></td>
            <td><input type="text" v-model="a.partida" class="form-control form-control-sm" /></td>
            <td><input type="checkbox" v-model="a.selected" /></td>
          </tr>
        </tbody>
      </table>
      <button class="btn btn-success" @click="cargarPagos">Cargar Pagos</button>
    </div>
    <div v-if="resultMessage" class="alert mt-3" :class="{'alert-success': resultSuccess, 'alert-danger': !resultSuccess}">
      {{ resultMessage }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'CargaPagEspecial',
  data() {
    return {
      mercados: [],
      selectedMercado: null,
      form: {
        oficina_pago: '',
        caja_pago: '',
        operacion_pago: '',
        fecha_pago: '',
        local: ''
      },
      adeudos: [],
      resultMessage: '',
      resultSuccess: false
    };
  },
  created() {
    this.fetchMercados();
  },
  methods: {
    async fetchMercados() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getMercados' })
      });
      const data = await res.json();
      if (data.success) {
        this.mercados = data.data;
      }
    },
    onMercadoChange() {
      if (this.selectedMercado) {
        this.form.oficina_pago = this.selectedMercado.oficina;
        this.form.local = '';
      }
    },
    async buscarAdeudos() {
      this.resultMessage = '';
      if (!this.selectedMercado || !this.form.local) {
        this.resultMessage = 'Seleccione un mercado y local válido.';
        this.resultSuccess = false;
        return;
      }
      const payload = {
        oficina: this.selectedMercado.oficina,
        mercado: this.selectedMercado.num_mercado_nvo,
        categoria: this.selectedMercado.categoria,
        seccion: 'SS',
        local: this.form.local
      };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getAdeudosLocal', payload })
      });
      const data = await res.json();
      if (data.success) {
        this.adeudos = data.data.map(a => ({ ...a, selected: true, partida: '' }));
      } else {
        this.resultMessage = data.message || 'Error al buscar adeudos.';
        this.resultSuccess = false;
      }
    },
    async cargarPagos() {
      this.resultMessage = '';
      const pagos = this.adeudos.filter(a => a.selected && a.partida && a.partida !== '0').map(a => ({
        id_local: a.id_local,
        axo: a.axo,
        periodo: a.periodo,
        importe: a.importe,
        partida: a.partida
      }));
      if (pagos.length === 0) {
        this.resultMessage = 'Debe seleccionar al menos un adeudo y capturar la partida.';
        this.resultSuccess = false;
        return;
      }
      const payload = {
        pagos,
        fecha_pago: this.form.fecha_pago,
        oficina_pago: this.form.oficina_pago,
        caja_pago: this.form.caja_pago,
        operacion_pago: this.form.operacion_pago,
        usuario_id: 1 // TODO: obtener del contexto de sesión
      };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'cargarPagosEspecial', payload })
      });
      const data = await res.json();
      this.resultMessage = data.message || (data.success ? 'Pagos cargados correctamente.' : 'Error al cargar pagos.');
      this.resultSuccess = !!data.success;
      if (data.success) {
        this.adeudos = [];
      }
    }
  }
};
</script>

<style scoped>
.carga-pag-especial {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  padding: 0.5rem 1rem;
  margin-bottom: 1rem;
}
</style>
