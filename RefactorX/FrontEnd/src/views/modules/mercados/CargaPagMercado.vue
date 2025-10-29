<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Carga Pag Mercado</h1>
        <p>Mercados - Gestión de Pagos</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <div class="carga-pag-mercado-page">
          <h1>Carga de Pagos por Mercado</h1>
          <nav class="breadcrumb">
            <span>Inicio</span> &gt; <span>Pagos</span> &gt; <span>Carga por Mercado</span>
          </nav>
          <form @submit.prevent="buscarAdeudos">
            <div class="form-row">
              <label>Recaudadora:</label>
              <select v-model="form.oficina" @change="cargarMercados">
                <option v-for="rec in recaudadoras" :key="rec.id" :value="rec.id">{{ rec.nombre }}</option>
              </select>
              <label>Mercado:</label>
              <select v-model="form.mercado" @change="setCategoria">
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">{{ merc.descripcion }}</option>
              </select>
              <label>Categoria:</label>
              <input v-model="form.categoria" readonly style="width:40px" />
              <label>Sección:</label>
              <select v-model="form.seccion">
                <option v-for="sec in secciones" :key="sec" :value="sec">{{ sec }}</option>
              </select>
              <label>Local:</label>
              <input v-model="form.local" style="width:60px" />
            </div>
            <div class="form-row">
              <label>Oficina Pago:</label>
              <select v-model="form.oficina_pago" @change="cargarCajas">
                <option v-for="rec in recaudadoras" :key="rec.id" :value="rec.id">{{ rec.nombre }}</option>
              </select>
              <label>Caja:</label>
              <select v-model="form.caja">
                <option v-for="caja in cajas" :key="caja" :value="caja">{{ caja }}</option>
              </select>
              <label>Operación:</label>
              <input v-model="form.operacion" style="width:80px" />
              <label>Fecha Ingreso:</label>
              <input type="date" v-model="form.fecha_ingreso" />
              <label>Fecha Pago:</label>
              <input type="date" v-model="form.fecha_pago" />
            </div>
            <div class="form-row">
              <button type="submit">Buscar Adeudos</button>
              <button type="button" @click="resetForm">Limpiar</button>
            </div>
          </form>
          <div v-if="adeudos.length">
            <h2>Adeudos del Local</h2>
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
                  <th>Control</th><th>Rec</th><th>Merc</th><th>Cat</th><th>Sec</th><th>Local</th><th>Letra</th><th>Bloque</th><th>Año</th><th>Mes</th><th>Renta</th><th>Partida</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in adeudos" :key="row.id_local" class="row-hover">
                  <td>{{ row.id_local }}</td>
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}</td>
                  <td>{{ row.local }}</td>
                  <td>{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>{{ row.axo }}</td>
                  <td>{{ row.periodo }}</td>
                  <td>{{ row.importe }}</td>
                  <td><input v-model="row.partida" style="width:60px" /></td>
                </tr>
              </tbody>
            </table>
            <div class="form-row">
              <button @click="grabarPagos">Grabar Pagos</button>
            </div>
            <div class="status-bar">
              <span>Importe Ingresado: <b>{{ status.importe_ingresado }}</b></span>
              <span>Importe Capturado: <b>{{ status.importe_capturado }}</b></span>
              <span>Importe por Capturar: <b>{{ status.importe_por_capturar }}</b></span>
            </div>
          </div>
          <div v-if="message" class="message">{{ message }}</div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'CargaPagMercado'"
      :moduleName="'mercados'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

export default {
  components: {
    DocumentationModal
  },
  name: 'CargaPagMercadoPage',
  data() {
    return {
      recaudadoras: [],
      mercados: [],
      secciones: [],
      cajas: [],
      form: {
        oficina: '',
        mercado: '',
        categoria: '',
        seccion: '',
        local: '',
        oficina_pago: '',
        caja: '',
        operacion: '',
        fecha_ingreso: '',
        fecha_pago: '',
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }},
      adeudos: [],
      status: {
        importe_ingresado: 0,
        importe_capturado: 0,
        importe_por_capturar: 0
      },
      message: ''
    }
  },
  mounted() {
    this.cargarRecaudadoras();
    this.cargarSecciones();
  },
  methods: {
    openDocumentation() {
      this.showDocumentation = true;
    },
    closeDocumentation() {
      this.showDocumentation = false;
    },
    showToast(type, message) {
      this.toast = { show: true, type, message };
      setTimeout(() => this.hideToast(), 3000);
    },
    hideToast() {
      this.toast.show = false;
    },
    getToastIcon(type) {
      const icons = {
        success: 'check-circle',
        error: 'exclamation-circle',
        warning: 'exclamation-triangle',
        info: 'info-circle'
      };
      return icons[type] || 'info-circle';
    },
    async cargarRecaudadoras() {
      // Simulación: Debe llamar a /api/execute con action=getRecaudadoras
      this.recaudadoras = [
        {id: 1, nombre: 'Centro'},
        {id: 2, nombre: 'Olímpica'},
        {id: 3, nombre: 'Oblatos'},
        {id: 4, nombre: 'Minerva'},
        {id: 5, nombre: 'Cruz del Sur'}
      ];
    },
    async cargarMercados() {
      if (!this.form.oficina) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({action: 'getMercados', params: {oficina: this.form.oficina}})
      });
      const data = await res.json();
      this.mercados = data.data || [];
    },
    setCategoria() {
      const merc = this.mercados.find(m => m.num_mercado_nvo == this.form.mercado);
      this.form.categoria = merc ? merc.categoria : '';
    },
    async cargarSecciones() {
      // Simulación: Debe llamar a /api/execute con action=getSecciones
      this.secciones = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'PS', 'SS'];
    },
    async cargarCajas() {
      if (!this.form.oficina_pago) return;
      // Simulación: Debe llamar a /api/execute con action=getCajas
      this.cajas = ['01', '02', '03', '04', '05'];
    },
    async buscarAdeudos() {
      this.message = '';
      if (!this.form.oficina || !this.form.mercado || !this.form.categoria || !this.form.seccion || !this.form.local) {
        this.message = 'Completa todos los campos para buscar.';
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          action: 'getAdeudosLocal',
          params: {
            oficina: this.form.oficina,
            mercado: this.form.mercado,
            categoria: this.form.categoria,
            seccion: this.form.seccion,
            local: this.form.local
          }
        })
      });
      const data = await res.json();
      this.adeudos = (data.data || []).map(row => ({...row, partida: ''}));
      // Actualizar status
      this.status.importe_ingresado = 0;
      this.status.importe_capturado = 0;
      this.status.importe_por_capturar = 0;
      // Aquí se puede llamar a getIngresoOperacion y getCapturaOperacion para actualizar status
    },
    async grabarPagos() {
      // Validar partidas
      const pagos = this.adeudos.filter(row => row.partida && row.partida !== '0');
      if (!pagos.length) {
        this.message = 'Debes ingresar al menos una partida.';
        return;
      }
      // Lógica de validación de importes, etc.
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          action: 'insertPagosMercado',
          params: {
            fecha_pago: this.form.fecha_pago,
            oficina: this.form.oficina_pago,
            caja: this.form.caja,
            operacion: this.form.operacion,
            usuario_id: 1, // Simulación
            mercado: this.form.mercado,
            categoria: this.form.categoria,
            seccion: this.form.seccion,
            pagos: pagos
          }
        })
      });
      const data = await res.json();
      if (data.success) {
        this.message = 'Pagos cargados correctamente.';
        this.buscarAdeudos();
      } else {
        this.message = data.message || 'Error al grabar pagos.';
      }
    },
    resetForm() {
      this.form = {
        oficina: '', mercado: '', categoria: '', seccion: '', local: '',
        oficina_pago: '', caja: '', operacion: '', fecha_ingreso: '', fecha_pago: ''
      };
      this.adeudos = [];
      this.status = {importe_ingresado: 0, importe_capturado: 0, importe_por_capturar: 0};
      this.message = '';
    }
  }
}
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
