<template>
  <div class="carga-pag-energia-elec">
    <h1>Carga de Pagos de Energía Eléctrica</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Carga de Pagos de Energía Eléctrica
    </div>
    <form @submit.prevent="buscarAdeudos">
      <fieldset>
        <legend>Datos del Local</legend>
        <div class="form-row">
          <label>Recaudadora:
            <select v-model="form.oficina" @change="cargarMercados">
              <option v-for="rec in recaudadoras" :key="rec.id" :value="rec.id">{{ rec.nombre }}</option>
            </select>
          </label>
          <label>Mercado:
            <select v-model="form.mercado">
              <option v-for="merc in mercados" :key="merc.id" :value="merc.id">{{ merc.descripcion }}</option>
            </select>
          </label>
          <label>Categoria:
            <input v-model="form.categoria" maxlength="1" />
          </label>
          <label>Sección:
            <select v-model="form.seccion">
              <option v-for="sec in secciones" :key="sec" :value="sec">{{ sec }}</option>
            </select>
          </label>
          <label>Local Desde:
            <input v-model="form.local_desde" type="number" min="1" />
          </label>
          <label>Local Hasta:
            <input v-model="form.local_hasta" type="number" min="1" />
          </label>
        </div>
        <button type="submit">Buscar Adeudos</button>
      </fieldset>
    </form>

    <div v-if="adeudos.length">
      <h2>Adeudos Encontrados</h2>
      <table class="table table-striped">
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
            <th>Cve</th>
            <th>Cant F/K</th>
            <th>Año</th>
            <th>Per</th>
            <th>Cuota</th>
            <th>Partida</th>
            <th>Seleccionar</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(adeudo, idx) in adeudos" :key="adeudo.id_energia">
            <td>{{ adeudo.id_energia }}</td>
            <td>{{ adeudo.oficina }}</td>
            <td>{{ adeudo.num_mercado }}</td>
            <td>{{ adeudo.categoria }}</td>
            <td>{{ adeudo.seccion }}</td>
            <td>{{ adeudo.local }}</td>
            <td>{{ adeudo.letra_local }}</td>
            <td>{{ adeudo.bloque }}</td>
            <td>{{ adeudo.cve_consumo }}</td>
            <td>{{ adeudo.cantidad }}</td>
            <td>{{ adeudo.axo }}</td>
            <td>{{ adeudo.periodo }}</td>
            <td>{{ adeudo.importe }}</td>
            <td>
              <input v-model="adeudo.partida" placeholder="Partida" />
            </td>
            <td>
              <input type="checkbox" v-model="adeudo.selected" />
            </td>
          </tr>
        </tbody>
      </table>
      <fieldset>
        <legend>Datos del Pago</legend>
        <div class="form-row">
          <label>Fecha de Pago:
            <input type="date" v-model="form.fecha_pago" />
          </label>
          <label>Oficina:
            <select v-model="form.oficina_pago" @change="cargarCajas">
              <option v-for="rec in recaudadoras" :key="rec.id" :value="rec.id">{{ rec.nombre }}</option>
            </select>
          </label>
          <label>Caja:
            <select v-model="form.caja_pago">
              <option v-for="caja in cajas" :key="caja.caja" :value="caja.caja">{{ caja.caja }}</option>
            </select>
          </label>
          <label>Operación:
            <input v-model="form.operacion_pago" type="number" />
          </label>
        </div>
        <button @click="cargarPagos">Cargar Pagos</button>
        <button @click="consultarPagos">Consultar Pagos</button>
      </fieldset>
    </div>

    <div v-if="pagos.length">
      <h2>Pagos Realizados</h2>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>ID Pago</th>
            <th>ID Energía</th>
            <th>Año</th>
            <th>Periodo</th>
            <th>Fecha Pago</th>
            <th>Oficina</th>
            <th>Caja</th>
            <th>Operación</th>
            <th>Importe</th>
            <th>Cve Consumo</th>
            <th>Cantidad</th>
            <th>Folio</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="pago in pagos" :key="pago.id_pago_energia">
            <td>{{ pago.id_pago_energia }}</td>
            <td>{{ pago.id_energia }}</td>
            <td>{{ pago.axo }}</td>
            <td>{{ pago.periodo }}</td>
            <td>{{ pago.fecha_pago }}</td>
            <td>{{ pago.oficina_pago }}</td>
            <td>{{ pago.caja_pago }}</td>
            <td>{{ pago.operacion_pago }}</td>
            <td>{{ pago.importe_pago }}</td>
            <td>{{ pago.cve_consumo }}</td>
            <td>{{ pago.cantidad }}</td>
            <td>{{ pago.folio }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="success" class="alert alert-success">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'CargaPagEnergiaElec',
  data() {
    return {
      form: {
        oficina: '',
        mercado: '',
        categoria: '',
        seccion: '',
        local_desde: '',
        local_hasta: '',
        fecha_pago: '',
        oficina_pago: '',
        caja_pago: '',
        operacion_pago: ''
      },
      recaudadoras: [],
      mercados: [],
      secciones: [],
      cajas: [],
      adeudos: [],
      pagos: [],
      error: '',
      success: ''
    }
  },
  created() {
    this.cargarRecaudadoras();
    this.cargarSecciones();
  },
  methods: {
    async cargarRecaudadoras() {
      // Simulación: Debe ser reemplazado por llamada real a API
      this.recaudadoras = [
        { id: 1, nombre: 'Centro' },
        { id: 2, nombre: 'Olímpica' },
        { id: 3, nombre: 'Oblatos' },
        { id: 4, nombre: 'Minerva' },
        { id: 5, nombre: 'Cruz del Sur' }
      ];
    },
    async cargarSecciones() {
      // Simulación: Debe ser reemplazado por llamada real a API
      this.secciones = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'PS', 'SS'];
    },
    async cargarMercados() {
      // Llamada real a API
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'consultarMercados',
          data: { oficina: this.form.oficina }
        })
      });
      const json = await res.json();
      this.mercados = json.data || [];
    },
    async cargarCajas() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'consultarCajas',
          data: { oficina: this.form.oficina_pago }
        })
      });
      const json = await res.json();
      this.cajas = json.data || [];
    },
    async buscarAdeudos() {
      this.error = '';
      this.success = '';
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'buscarAdeudos',
          data: {
            oficina: this.form.oficina,
            mercado: this.form.mercado,
            categoria: this.form.categoria,
            seccion: this.form.seccion,
            local_desde: this.form.local_desde,
            local_hasta: this.form.local_hasta
          }
        })
      });
      const json = await res.json();
      if (json.success) {
        this.adeudos = (json.data || []).map(a => ({ ...a, selected: false, partida: '' }));
      } else {
        this.error = json.message || 'Error al buscar adeudos';
      }
    },
    async cargarPagos() {
      this.error = '';
      this.success = '';
      const pagos = this.adeudos.filter(a => a.selected && a.partida && a.partida !== '0').map(a => ({
        id_energia: a.id_energia,
        axo: a.axo,
        periodo: a.periodo,
        importe: a.importe,
        cve_consumo: a.cve_consumo,
        cantidad: a.cantidad,
        folio: a.partida
      }));
      if (!pagos.length) {
        this.error = 'Debe seleccionar al menos un adeudo y capturar la partida';
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'cargarPagos',
          data: {
            pagos,
            usuario_id: 1, // Debe obtenerse del login
            fecha_pago: this.form.fecha_pago,
            oficina_pago: this.form.oficina_pago,
            caja_pago: this.form.caja_pago,
            operacion_pago: this.form.operacion_pago
          }
        })
      });
      const json = await res.json();
      if (json.success) {
        this.success = 'Pagos cargados correctamente';
        this.buscarAdeudos();
      } else {
        this.error = json.message || 'Error al cargar pagos';
      }
    },
    async consultarPagos() {
      this.error = '';
      this.success = '';
      // Tomar el primer adeudo seleccionado
      const adeudo = this.adeudos.find(a => a.selected);
      if (!adeudo) {
        this.error = 'Debe seleccionar un adeudo para consultar pagos';
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'consultarPagos',
          data: { id_energia: adeudo.id_energia }
        })
      });
      const json = await res.json();
      if (json.success) {
        this.pagos = json.data || [];
      } else {
        this.error = json.message || 'Error al consultar pagos';
      }
    }
  }
}
</script>

<style scoped>
.carga-pag-energia-elec {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 1rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.alert {
  margin-top: 1rem;
  padding: 1rem;
}
.alert-danger {
  background: #f8d7da;
  color: #721c24;
}
.alert-success {
  background: #d4edda;
  color: #155724;
}
</style>
