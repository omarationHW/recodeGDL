<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div>
      <div class="module-view-info">
        <h1>Transferencia de Documentos</h1>
        <p>Mercados - Transferencia de Documentos</p>
      </div>
    </div>

    <div class="module-view-content">
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h3>Transferencia de Documentos</h3>
      </div>
      <div class="municipal-card-body">
        <form @submit.prevent="onBuscar">
          <div class="row mb-3">
            <div class="col-md-3">
              <label class="municipal-form-label" for="fecha">Fecha Elaboración</label>
              <input type="date" v-model="form.fecha_elaboracion" class="municipal-form-control" required />
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label" for="cuenta">Cuenta</label>
              <select v-model="form.cuenta" class="municipal-form-control" @change="onCuentaChange">
                <option v-for="cta in cuentas" :key="cta.id" :value="cta.id">
                  {{ cta.nombre }}
                </option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label" for="tipo_doc">Tipo de Documento</label>
              <div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="cheques" value="C" v-model="form.tipo_doc" />
                  <label class="form-check-label" for="cheques">Cheques</label>
                </div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="pagador" value="P" v-model="form.tipo_doc" />
                  <label class="form-check-label" for="pagador">Elec. Bco. Pagador</label>
                </div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="otros" value="O" v-model="form.tipo_doc" />
                  <label class="form-check-label" for="otros">Elec. Otros Bancos</label>
                </div>
              </div>
            </div>
            <div class="col-md-3 align-self-end">
              <button type="submit" class="btn-municipal-primary">Buscar</button>
            </div>
          </div>
        </form>
        <div v-if="documentos.length">
          <h5>Documentos encontrados: {{ documentos.length }}</h5>
          <div class="table-responsive">
            <table class="-bordered municipal-table-sm">
              <thead>
                <tr>
                  <th>Cheque</th>
                  <th>Fecha Elaboración</th>
                  <th>Importe</th>
                  <th>Ejercicio</th>
                  <th>Procedencia</th>
                  <th>Contrarecibo</th>
                  <th>Beneficiario</th>
                  <th>Forma de Pago</th>
                  <th>Cuenta</th>
                  <th>Proveedor</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="doc in documentos" :key="doc.id_ctrl_cheque">
                  <td>{{ doc.cheque }}</td>
                  <td>{{ doc.fecha_elaboracion }}</td>
                  <td>{{ doc.importe }}</td>
                  <td>{{ doc.ejercicio }}</td>
                  <td>{{ doc.procedencia }}</td>
                  <td>{{ doc.contrarecibo }}</td>
                  <td>{{ doc.beneficiario }}</td>
                  <td>{{ doc.forma_pago }}</td>
                  <td>{{ doc.nombre }}</td>
                  <td>{{ doc.id_proveedor }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <button class="btn btn-municipal-success mt-3" @click="onGenerarTransferencia">Generar Archivo de Transferencia</button>
        </div>
        <div v-else-if="buscado">
          <div class="alert alert-warning">No se encontraron documentos para los criterios seleccionados.</div>
        </div>
      </div>
    </div>
    <!-- Modal para descarga -->
    <div class="modal fade" id="modalDescarga" tabindex="-1" role="dialog" aria-labelledby="modalDescargaLabel" aria-hidden="true" ref="modalDescarga">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="modalDescargaLabel">Archivo generado</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close" @click="closeModal">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <p>El archivo de transferencia ha sido generado. <a :href="archivoUrl" download>Descargar archivo</a></p>
          </div>
        </div>
      </div>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
import axios from 'axios';
export default {
  name: 'TrDocumentos',
  data() {
    return {
      form: {
        fecha_elaboracion: '',
        cuenta: '',
        tipo_doc: 'C',
      },
      cuentas: [],
      documentos: [],
      bancos: [],
      archivoUrl: '',
      buscado: false
    };
  },
  mounted() {
    this.form.fecha_elaboracion = new Date().toISOString().substr(0, 10);
    this.loadCuentas();
    this.loadBancos();
  },
  methods: {
    async loadCuentas() {
      // Simulación: en real, pedir a API
      // Aquí se asume que el usuario tiene acceso a ciertas cuentas
      // En producción, pedir a /api/execute con getCuentasTrans
      this.cuentas = [
        { id: 1, nombre: 'Cuenta 1', moneda: 1, cta_mayor: 1102, cta_sub01: 3, cta_sub02: 1, cta_sub03: 7 },
        // ...
      ];
      this.form.cuenta = this.cuentas[0].id;
    },
    async loadBancos() {
      // Simulación: en real, pedir a API
      this.bancos = [
        { banco: 1, nombre: 'Banco 1', pagador: 'S' },
        // ...
      ];
    },
    onCuentaChange() {
      // Si se requiere cargar info adicional de la cuenta
    },
    async onBuscar() {
      this.buscado = false;
      const cuenta = this.cuentas.find(c => c.id === this.form.cuenta);
      let params = {
        fecha_elaboracion: this.form.fecha_elaboracion,
        moneda: cuenta.moneda,
        cta_mayor: cuenta.cta_mayor,
        cta_sub01: cuenta.cta_sub01,
        cta_sub02: cuenta.cta_sub02,
        cta_sub03: cuenta.cta_sub03,
        forma_pago: this.form.tipo_doc,
        banco: this.form.tipo_doc === 'P' ? this.bancos[0].banco : null
      };
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: {
            operation: 'getDocumentos',
            params
          }
        });
        this.documentos = data.eResponse.data || [];
        this.buscado = true;
      } catch (e) {
        alert('Error al buscar documentos');
      }
    },
    async onGenerarTransferencia() {
      if (!this.documentos.length) return;
      const cuenta = this.cuentas.find(c => c.id === this.form.cuenta);
      let params = {
        tipo_doc: this.form.tipo_doc,
        fecha: this.form.fecha_elaboracion,
        moneda: cuenta.moneda,
        cta_mayor: cuenta.cta_mayor,
        cta_sub01: cuenta.cta_sub01,
        cta_sub02: cuenta.cta_sub02,
        documentos: this.documentos
      };
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: {
            operation: 'generarTransferencia',
            params
          }
        });
        if (data.eResponse.status === 'ok' && data.eResponse.data && data.eResponse.data[0].archivo_url) {
          this.archivoUrl = data.eResponse.data[0].archivo_url;
          $(this.$refs.modalDescarga).modal('show');
        } else {
          alert('No se pudo generar el archivo');
        }
      } catch (e) {
        alert('Error al generar archivo de transferencia');
      }
    },
    closeModal() {
      $(this.$refs.modalDescarga).modal('hide');
    }
  }
};
</script>

<style scoped>
.tr-documentos-page {
  max-width: 1200px;
  margin: 0 auto;
}
</style>
